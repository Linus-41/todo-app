//
//  SignUpView.swift
//  todo-app
//
//  Created by Linus Widing on 08.09.24.
//

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
            SecureField("Confirm password", text: $signUpViewModel.confirmPassword)
            if let errorMessage = signUpViewModel.errorMessage{
                Text("Error: \(errorMessage)")
                    .foregroundStyle(.red)
            }
            
            Button("Sign up ", action: {
                
                if validatePassword(){
                    signUpViewModel.signUp()
                }
                else{
                    signUpViewModel.errorMessage = "Passwords not matching!"
                }
            })
                .buttonStyle(.borderedProminent)
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .onChange(of: signUpViewModel.isSignedUp, initial: false) { oldValue, newValue in
            presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    private func validatePassword() -> Bool{
        return signUpViewModel.password == signUpViewModel.confirmPassword
    }
}

#Preview {
    SignUpView(signUpViewModel: SignUpViewModel())
}
