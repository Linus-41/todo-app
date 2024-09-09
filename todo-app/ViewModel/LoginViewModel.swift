import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var showError: Bool = false
    
    func login() {
        APIService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Access Token: \(token)")
                    self.isLoggedIn = true
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self.showError = true
                }
            }
        }
    }
}
