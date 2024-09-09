import SwiftUI

struct SignUpView: View {
    @ObservedObject var signUpViewModel: SignUpViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack{
                Text("Sign up ")
                    .font(.system(size: 20))
                    .italic()
                
                Spacer()
            }
            TextField("Username", text: $signUpViewModel.username)
                .autocapitalization(.none)
            
            SecureField("Password", text: $signUpViewModel.password)
                .textContentType(.newPassword)
            SecureField("Confirm password", text: $signUpViewModel.confirmPassword)
                .textContentType(.newPassword)
            if let errorMessage = signUpViewModel.errorMessage{
                Text("Error: \(errorMessage)")
                    .foregroundStyle(.red)
            }
            
            Button("Sign up ", action: {
                
                if signUpViewModel.isValid(){
                    signUpViewModel.signUp()
                }
                else{
                    signUpViewModel.errorMessage = "Passwords not matching!"
                }
            })
            .buttonStyle(.borderedProminent)
            .disabled(!signUpViewModel.isValid())
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .onChange(of: signUpViewModel.isSignedUp, initial: false) { oldValue, newValue in
            presentationMode.wrappedValue.dismiss()
        }
        
    }
}

#Preview {
    SignUpView(signUpViewModel: SignUpViewModel())
}
