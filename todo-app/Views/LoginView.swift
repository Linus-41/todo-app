import SwiftUI

struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    
    var body: some View {
        VStack {
            Text("Todo App")
                .font(.system(size: 50))
                .bold()
            Spacer()
            TextField("Username", text: $loginViewModel.username)
                .autocapitalization(.none)
            
            SecureField("Password", text: $loginViewModel.password)
            
            
            Button("Sign in ", action: loginViewModel.login)
                .buttonStyle(.borderedProminent)
            
            Spacer()
            Text("Not signed up yet?")
                .foregroundStyle(.gray)
            Button("Sign up", action: {
                // Sign up todo 
            })
        }
        .textFieldStyle(.roundedBorder)
        .padding()
    }
}


#Preview {
    LoginView(loginViewModel: LoginViewModel())
}
