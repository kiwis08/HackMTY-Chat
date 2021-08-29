//
//  RegistrationView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var email = ""
    @State private var username = ""
    @State private var password1 = ""
    @State private var password2 = ""
    
    @State private var validEmail = false
    @State private var errorModel: ErrorModel? = nil
    
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
            
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            LoginNameTextField(placeholder: "Username", text: $username)
                  
            LoginEmailTextField(placeholder: "Email address", text: $email)
            
            LoginPasswordTextField(placeholder: "Enter your password", text: $password1)
            
            LoginPasswordTextField(placeholder: "Re-enter your password", text: $password2)
            
            Button("Continue") {
                guard verifyEmail(email) else {
                    self.errorModel = ErrorModel(title: "Check your email address", message: "Please check you entered a valid email address")
                    return
                }
                guard password1 == password2 else {
                    self.errorModel = ErrorModel(title: "Error", message: "Password does not match")
                    return
                }
                
                self.validEmail = true
                signUp { errorModel in
                    self.errorModel = errorModel
                    if errorModel == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }.buttonStyle(BlueButton())
            
            Spacer()
        }
        .alert(item: $errorModel) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK"), action: {
                if validEmail {
                    presentationMode.wrappedValue.dismiss()
                }
            }))
        }
    }
    
    func verifyEmail(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    func signUp(completion: @escaping (ErrorModel?) -> Void) {
        Auth.auth().createUser(withEmail: self.email, password: self.password1) { (result, error) in
            guard let result = result else {
                print("Error creating user: \(error!)")
                completion(ErrorModel(title: "Error", message: error!.localizedDescription))
                return
            }
            let db = Firestore.firestore()
            let newUser = User(id: result.user.uid, name: self.username, email: self.email.lowercased())
            do {
                print("Creating document with id: \(newUser.id)")
                try db.collection("users").document(newUser.id).setData(from: newUser)
                completion(nil)
            } catch {
                print("Error adding document from user: \(error)")
                completion(ErrorModel(title: "Error", message: error.localizedDescription))
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}

