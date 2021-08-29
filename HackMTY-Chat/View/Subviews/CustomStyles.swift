//
//  CustomStyles.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI

struct CustomTextField: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .frame(width: 250, height: 10)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    

}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

fileprivate struct LoginTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(colorScheme == .dark ? Color.white.opacity(0.8) : Color.gray.opacity(0.6))
            .cornerRadius(15)
            .padding(.horizontal)
            .foregroundColor(colorScheme == .dark ? Color.black: Color.white)
            .autocapitalization(.none)
    }
}

struct LoginNameTextField: View {
    @Environment(\.colorScheme) var colorScheme
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading, content: {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(colorScheme == .dark ? .gray : Color.gray.opacity(0.8))
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.name)
        })
    }
}

struct LoginEmailTextField: View {
    @Environment(\.colorScheme) var colorScheme
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading, content: {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(colorScheme == .dark ? .gray : Color.gray.opacity(0.8))
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.emailAddress)
                .disableAutocorrection(true)
        })
    }
}

struct LoginPasswordTextField: View {
    @Environment(\.colorScheme) var colorScheme
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading, content: {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(colorScheme == .dark ? Color.gray : Color.gray.opacity(0.8))
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .allowsHitTesting(false)
            }
            SecureField("", text: $text)
                .textFieldStyle(LoginTextFieldStyle())
                .textContentType(.password)
        })
    }
}

struct MajorTextField: View {
    @Environment(\.colorScheme) var colorScheme
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .leading, content: {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(colorScheme == .dark ? .gray : Color.gray.opacity(0.8))
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .textFieldStyle(LoginTextFieldStyle())
                .disableAutocorrection(true)
        })
    }
}
