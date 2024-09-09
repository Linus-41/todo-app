import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:8000"
    
    private var authToken: String? {
        UserDefaults.standard.string(forKey: "authToken")
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
            
            guard let data = data else{
                return
            }
            
            if response.statusCode == 200{
                do {
                    let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self.saveToken(tokenResponse.access_token)
                    completion(.success(tokenResponse.access_token))
                } catch {
                    completion(.failure(error))
                }
            }
            else{
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
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let error = NSError(domain: "Sign-up failed", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
    
    
    func fetchTodos(excludeDone: Bool = false, excludeShared: Bool = false, skip: Int = 0, limit: Int = 100, completion: @escaping (Result<[Todo], Error>) -> Void) {
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
        
        // Add the Authorization header
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
                let error = NSError(domain: "No data", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            // Log the raw response
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
        
        // Add the Authorization header
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
                let error = NSError(domain: "Server error", code: -1, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
        task.resume()
    }
    
    // New function to delete a todo
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
                let error = NSError(domain: "Server error", code: -1, userInfo: nil)
                completion(.failure(error))
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
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
}
