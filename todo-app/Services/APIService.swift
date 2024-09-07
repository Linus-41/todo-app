import Foundation

class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:8000"

    private var authToken: String? {
        UserDefaults.standard.string(forKey: "authToken")
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
}
