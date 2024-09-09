import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isSignedUp: Bool = false
    @Published var errorMessage: String?
    
    func signUp(contentViewModel: ContentViewModel) {
        APIService.shared.signUp(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.loginAfterSignUp(contentViewModel: contentViewModel)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func isValid()->Bool{
        if username.isEmpty || password.isEmpty || confirmPassword.isEmpty{
            return false
        }
        
        if password != confirmPassword{
            return false
        }
        return true
    }
    
    private func loginAfterSignUp(contentViewModel: ContentViewModel){
        APIService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Access Token: \(token)")
                    contentViewModel.isSignedIn = true
                case .failure(let error):
                    print("Login failed: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
