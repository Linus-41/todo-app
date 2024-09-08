import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var signUpViewModel = SignUpViewModel()
    
    var body: some View {
        NavigationStack {
            if loginViewModel.isLoggedIn || signUpViewModel.isSignedUp{
                TodoListView()
            } else {
                LoginView(loginViewModel: loginViewModel, signUpViewModel: signUpViewModel)
            }
        }
    }
}
