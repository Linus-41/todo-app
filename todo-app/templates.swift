//
//  Modifiers.swift
//  todo-app
//
//  Created by Linus Widing on 14.09.24.
//

import Foundation
import SwiftUI

struct CustomButton: View{
    var text: String
    var action: () -> Void
    
    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View{
        Button(action: action, label: {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        })
        .buttonStyle(.borderedProminent)
    }
}

struct CustomTextFieldModifier: ViewModifier{
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
            .background(Color("GrayTransparent"))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("GrayBorder"), lineWidth: 0.5))
            
    }
}

#Preview{
    struct Preview: View {
        @State var test = ""
        
        var body: some View {
            TextField("Test", text: $test)
                .modifier(CustomTextFieldModifier())

        }
    }
    return Preview().padding(20)
}
