import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:8000"
    
    // Access and Refresh tokens
    private var authToken: String? {
        get { UserDefaults.standard.string(forKey: "authToken") }
        set { UserDefaults.standard.set(newValue, forKey: "authToken") }
    }
    
    private var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refreshToken") }
        set { UserDefaults.standard.set(newValue, forKey: "refreshToken") }
    }
    
    private var tokenExpiration: Date? {
        get { UserDefaults.standard.object(forKey: "tokenExpiration") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "tokenExpiration") }
    }
    
    // Check if access token has expired
    private var isTokenExpired: Bool {
        if let expiration = tokenExpiration {
            return Date() >= expiration
        }
        return true
    }
    
    // Function to login and get both access and refresh tokens
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/token") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = "username=\(username)&password=\(password)&grant_type=password"
        request.httpBody = bodyParams.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            if response.statusCode == 200 {
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self.saveToken(tokenResponse.access_token, refreshToken: tokenResponse.refresh_token, expiresIn: 1800)  // 30 min
                    completion(.success(tokenResponse.access_token))
                } catch {
                    completion(.failure(error))
                }
            } else {
                do {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    let customError = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.detail])
                    completion(.failure(customError))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // Function to sign up a new user
    func signUp(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let user = UserCreate(user_name: username, password: password)
        guard let encodedUser = try? JSONEncoder().encode(user) else {
            completion(.failure(NSError(domain: "Encoding Error", code: -1, userInfo: nil)))
            return
        }
        
        request.httpBody = encodedUser
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                let error = NSError(domain: "Sign-up failed", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
    
    // Function to refresh the access token using refresh token
    private func refreshAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = self.refreshToken else {
            completion(.failure(NSError(domain: "Missing refresh token", code: -1, userInfo: nil)))
            return
        }

        guard let url = URL(string: "\(baseURL)/refresh") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParams = "refresh_token=\(refreshToken)"
        request.httpBody = bodyParams.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            guard let data = data else { return }
            
            if response.statusCode == 200 {
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self.saveToken(tokenResponse.access_token, refreshToken: tokenResponse.refresh_token, expiresIn: 1800)
                    completion(.success(tokenResponse.access_token))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "Failed to refresh token", code: response.statusCode, userInfo: nil)))
            }
        }
        task.resume()
    }

    // Function to fetch todos with token refreshing logic
    func fetchTodos(excludeDone: Bool = false, excludeShared: Bool = false, skip: Int = 0, limit: Int = 100, completion: @escaping (Result<[Todo], Error>) -> Void) {
        if isTokenExpired {
            refreshAccessToken { result in
                switch result {
                case .success:
                    self.executeFetchTodos(excludeDone: excludeDone, excludeShared: excludeShared, skip: skip, limit: limit, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            executeFetchTodos(excludeDone: excludeDone, excludeShared: excludeShared, skip: skip, limit: limit, completion: completion)
        }
    }

    // Private helper function to execute the fetchTodos call
    private func executeFetchTodos(excludeDone: Bool, excludeShared: Bool, skip: Int, limit: Int, completion: @escaping (Result<[Todo], Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)/todos/")!
        components.queryItems = [
            URLQueryItem(name: "exclude_done", value: String(excludeDone)),
            URLQueryItem(name: "exclude_shared", value: String(excludeShared)),
            URLQueryItem(name: "skip", value: String(skip)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Missing auth token", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            do {
                let todos = try JSONDecoder().decode([Todo].self, from: data)
                completion(.success(todos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func toggleTodoStatus(todoId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseURL)/todos/\(todoId)/toggle_status"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Missing auth token", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Server error", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
    
    func deleteTodo(todoId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "\(baseURL)/todos/\(todoId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Missing auth token", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
                completion(.failure(NSError(domain: "Server error", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
    
    func createTodo(todo: TodoCreate, completion: @escaping (Result<Todo, Error>) -> Void) {
        let urlString = "\(baseURL)/todos/"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NSError(domain: "Missing auth token", code: -1, userInfo: nil)))
            return
        }
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(todo)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let newTodo = try JSONDecoder().decode(Todo.self, from: data)
                completion(.success(newTodo))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func saveToken(_ accessToken: String, refreshToken: String, expiresIn: TimeInterval) {
        self.authToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiration = Date().addingTimeInterval(expiresIn)
    }
}
