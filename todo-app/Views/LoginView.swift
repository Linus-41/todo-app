import SwiftUI

struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack {
            TextField("Username", text: $loginViewModel.username)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $loginViewModel.password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                loginViewModel.login()
            }) {
                Text("Login")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
