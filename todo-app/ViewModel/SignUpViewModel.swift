import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isSignedUp: Bool = false
    @Published var errorMessage: String?
    
    func signUp() {
        APIService.shared.signUp(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loginAfterSignUp()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loginAfterSignUp(){
        APIService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Access Token: \(token)")
                    self.isSignedUp = true
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
