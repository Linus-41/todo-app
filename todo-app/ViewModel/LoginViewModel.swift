import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    
    func login() {
        APIService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Access Token: \(token)")
                    self.isLoggedIn = true
                case .failure(let error):
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func isValid()-> Bool{
        return !username.isEmpty && !password.isEmpty
    }
}
