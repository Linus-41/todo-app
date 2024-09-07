import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            if loginViewModel.isLoggedIn {
                TodoListView()
            } else {
                LoginView(loginViewModel: loginViewModel)
            }
        }
    }
}
