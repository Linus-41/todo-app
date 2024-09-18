import SwiftUI

struct LoginView: View {
    @EnvironmentObject var contentViewModel:ContentViewModel
    @StateObject var loginViewModel = LoginViewModel()
    @State var showingRegisterSheet: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack {
                
                Image("minimalistic-todo-app")
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Text("Login to EasyTodo")
                    .font(.system(size: 30))
                
                
                VStack{
                    TextField("Username", text: $loginViewModel.username)
                        .autocapitalization(.none)
                        .modifier(CustomTextFieldModifier())
                    
                    SecureField("Password", text: $loginViewModel.password)
                        .modifier(CustomTextFieldModifier())
                    
                    HStack{
                        Toggle("Stay logged in?", isOn: $loginViewModel.stayLoggedIn)
                            .toggleStyle(iOSCheckboxToggleStyle())
                        Text("Stay logged in")
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    
                    if let errorMessage = loginViewModel.errorMessage{
                        Text("Error: \(errorMessage)")
                            .foregroundStyle(.red)
                    }
                    
                    CustomButton("Sign in ", action: {
                        loginViewModel.login(contentViewModel: contentViewModel)
                    })
                    .disabled(!loginViewModel.isValid())
                }
                
                Spacer()
                Text("Not signed up yet?")
                    .foregroundStyle(.gray)
                Button("Create new account", action: {
                    showingRegisterSheet = true
                })
            }
            .padding()
            .sheet(isPresented: $showingRegisterSheet) {
                RegisterView()
            }
        }
    }
}


#Preview {
    LoginView()
}
