import SwiftUI

struct RegisterView: View {
    @StateObject var registerViewModel = RegisterViewModel()
    @EnvironmentObject var contentViewModel:ContentViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Sign up to EasyTodo")
                    .font(.system(size: 30))
                
                VStack{
                    TextField("Username", text: $registerViewModel.username)
                        .autocapitalization(.none)
                        .modifier(CustomTextFieldModifier())
                    
                    SecureField("Password", text: $registerViewModel.password)
                        .modifier(CustomTextFieldModifier())
                    
                    SecureField("Confirm password", text: $registerViewModel.confirmPassword)
                        .modifier(CustomTextFieldModifier())
                    
                    if let errorMessage = registerViewModel.errorMessage{
                        Text("Error: \(errorMessage)")
                            .foregroundStyle(.red)
                    }
                    
                    CustomButton("Sign up ", action: {
                        registerViewModel.signUp(contentViewModel: contentViewModel)
                    })
                    .disabled(!registerViewModel.isValid())
                    
                    Spacer()
                    
                }
            }
            .padding()
            .toolbar(content: {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            })
        }
    }
}

#Preview {
    RegisterView()
}
