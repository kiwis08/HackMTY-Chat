//
//  PasswordResetView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase

struct PasswordResetView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var email = ""
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("Close button")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .padding()
                }
                Spacer()
            }
            
            Text("Forgot Password?")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("What's your email address?")
                .font(.title3)
                .fontWeight(.medium)
                .padding(.top)
            LoginEmailTextField(placeholder: "Email address", text: $email)
            
            
            Text("If an account exists with this email, you'll receive an email with a password reset link.")
                .font(.subheadline)
                .fontWeight(.light)
                .padding()
            
            Button("Send Link") {
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                }
                presentationMode.wrappedValue.dismiss()
            }.buttonStyle(BlueButton())
            
            Spacer()
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}

