import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var showError: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func login() {
        guard let url = URL(string: "http://127.0.0.1:8000/token") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParams = "username=\(username)&password=\(password)&grant_type=password"
        request.httpBody = bodyParams.data(using: .utf8)

        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self.showError = true
                case .finished:
                    break
                }
            }, receiveValue: { tokenResponse in
                print("Access Token: \(tokenResponse.access_token)")
                self.saveToken(tokenResponse.access_token)
                self.isLoggedIn = true
            })
            .store(in: &self.cancellables)
    }

    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
}
