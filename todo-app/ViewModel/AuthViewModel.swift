import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    
    func login() {
        // Simple login check (replace with your authentication logic)
        if username == "user" && password == "password" {
            isLoggedIn = true
        }
    }
}
