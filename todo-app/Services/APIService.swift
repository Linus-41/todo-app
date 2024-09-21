import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:8000"
    
    private var authToken: String? {
        get { KeychainService.shared.getAccessToken() }
        set { if let newValue = newValue { KeychainService.shared.saveAccessToken(newValue) } else { KeychainService.shared.delete(key: "accessToken") } }
    }
    
    private var refreshToken: String? {
        get { KeychainService.shared.getRefreshToken() }
        set { if let newValue = newValue { KeychainService.shared.saveRefreshToken(newValue) } else { KeychainService.shared.delete(key: "refreshToken") } }
    }
    
    private var tokenExpiration: Date? {
        get { KeychainService.shared.getTokenExpiration() }
        set { if let newValue = newValue { KeychainService.shared.saveTokenExpiration(newValue) } else { KeychainService.shared.deleteTokenExpiration() } }
    }
    
    private var isTokenExpired: Bool {
        guard let expiration = tokenExpiration else { return true }
        return Date() >= expiration
    }
    
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
                    self.saveToken(tokenResponse.access_token, refreshToken: tokenResponse.refresh_token, expiresIn: 60)
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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the JSON body
        let bodyParams = ["refresh_token": refreshToken]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: bodyParams, options: []) else {
            completion(.failure(NSError(domain: "Encoding error", code: -1, userInfo: nil)))
            return
        }
        request.httpBody = httpBody

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
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

    
    func invalidateRefreshToken(toInvalidateToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/invalidate-token") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["token": toInvalidateToken]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
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
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalidation failed", code: -1, userInfo: nil)))
                return
            }
            
            // If the token invalidation was successful, remove the refresh token from the keychain
            self.refreshToken = nil
            self.authToken = nil
            self.tokenExpiration = nil
            
            completion(.success(()))
        }
        task.resume()
    }

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
            
            do {
                let todos = try JSONDecoder().decode([Todo].self, from: data)
                print(todos)
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
    
    func fetchCategories(skip: Int = 0, limit: Int = 100, completion: @escaping (Result<[Category], Error>) -> Void) {
        if isTokenExpired {
            refreshAccessToken { result in
                switch result {
                case .success:
                    self.executeFetchCategories(skip: skip, limit: limit, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            executeFetchCategories(skip: skip, limit: limit, completion: completion)
        }
    }
    
    private func executeFetchCategories(skip: Int = 0, limit: Int = 100, completion: @escaping (Result<[Category], Error>) -> Void) {
        var components = URLComponents(string: "\(baseURL)/categories/")!
        components.queryItems = [
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
            
            do {
                let categories = try JSONDecoder().decode([Category].self, from: data)
                print(categories)
                completion(.success(categories))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func createCategory(category: CategoryCreate, completion: @escaping (Result<Category, Error>) -> Void) {
        if isTokenExpired {
            refreshAccessToken { result in
                switch result {
                case .success:
                    self.executeCreateCategory(category: category, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            executeCreateCategory(category: category, completion: completion)
        }
    }
    
    private func executeCreateCategory(category: CategoryCreate, completion: @escaping (Result<Category, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories/") else {
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
        
        do {
            let jsonData = try JSONEncoder().encode(category)
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
                let newCategory = try JSONDecoder().decode(Category.self, from: data)
                completion(.success(newCategory))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func deleteCategory(categoryId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        if isTokenExpired {
            refreshAccessToken { result in
                switch result {
                case .success:
                    self.executeDeleteCategory(categoryId: categoryId, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            executeDeleteCategory(categoryId: categoryId, completion: completion)
        }
    }
    
    private func executeDeleteCategory(categoryId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/categories/\(categoryId)") else {
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
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(())) // Assuming successful deletion
        }
        task.resume()
    }
    
    private func saveToken(_ accessToken: String, refreshToken: String, expiresIn: TimeInterval) {
        self.authToken = accessToken
        self.refreshToken = refreshToken
        self.tokenExpiration = Date().addingTimeInterval(expiresIn)
    }
}
