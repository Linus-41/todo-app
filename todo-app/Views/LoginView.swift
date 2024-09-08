import SwiftUI

struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    var signUpViewModel: SignUpViewModel
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Todo App")
                    .font(.system(size: 50))
                    .bold()
                Spacer()
                
                HStack{
                    Text("Sign in ")
                        .font(.system(size: 20))
                        .italic()
                        
                    Spacer()
                }
                
                TextField("Username", text: $loginViewModel.username)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $loginViewModel.password)
                
                
                Button("Sign in ", action: loginViewModel.login)
                    .buttonStyle(.borderedProminent)
                
                Spacer()
                Text("Not signed up yet?")
                    .foregroundStyle(.gray)
                NavigationLink("Create new account", destination: 
                                SignUpView(signUpViewModel: signUpViewModel))
            }
            .textFieldStyle(.roundedBorder)
            .padding()
        }
    }
}


#Preview {
    LoginView(loginViewModel: LoginViewModel(), signUpViewModel: SignUpViewModel())
}
