import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var stayLoggedIn: Bool = false
    @Published var errorMessage: String?
    
    func login(contentViewModel: ContentViewModel) {
        contentViewModel.clearKeyChain()
        APIService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("Access Token: \(token)")
                    if self.stayLoggedIn{
                        UserDefaults.standard.set(self.stayLoggedIn, forKey: "stayLoggedIn")
                    }
                    contentViewModel.isSignedIn = true
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
