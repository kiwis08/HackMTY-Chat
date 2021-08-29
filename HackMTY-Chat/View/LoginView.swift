//
//  LoginView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase

fileprivate enum ActiveSheet: Identifiable {
    case registration, password
    
    var id: Int {
        hashValue
    }
}

struct LoginView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var userData: UserData
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var activeSheet: ActiveSheet?
    
    @Binding var errorModel: ErrorModel?
    
    var body: some View {
        VStack {
            Text("Welcome back")
                .font(.title2)
                .fontWeight(.regular)
            
            
            VStack {
                LoginEmailTextField(placeholder: "Email address", text: $email)
                    .padding(.vertical)
                
                LoginPasswordTextField(placeholder: "Password", text: $password)
                
                HStack {
                    Spacer()
                    Button(action: {
                        self.activeSheet = .password
                    }, label: {
                        Text("Forgot password?")
                            .foregroundColor(.blue)
                        
                    })
                    .padding(.horizontal)
                }
                
            }
            .padding(.vertical)
            
            Button(action: {
                self.login()
            }) {
                
                Text("Log in")
                    .foregroundColor(.black)
                
            }
            .buttonStyle(BlueButton())
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                
                Button {
                    self.activeSheet = .registration
                } label: {
                    Text("Sign up")
                        .foregroundColor(.blue)
                    
                }
                
            }
            .padding()
        }
        .alert(item: $errorModel) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK")))
        }
        .sheet(item: $activeSheet, onDismiss: {
            activeSheet = nil
        }) { sheet in
            switch sheet {
            case .password:
                PasswordResetView(email: email)
            case .registration:
                RegistrationView(email: email)
            }
        }
    }
    
    
    func login() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.errorModel = ErrorModel(message: "Incorrect email or password.")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            guard let res = result else {
                guard let error = err as NSError? else { return }
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    var errorTitle = "Error"
                    var errorMessage = ""
                    switch errorCode {
                    case .userDisabled:
                        errorMessage = "This account has been disabled. Please contact an administrator."
                    case .invalidEmail:
                        errorMessage = "Invalid email address."
                    case .wrongPassword:
                        errorMessage = "Incorrect email and/or password."
                    case .tooManyRequests:
                        errorMessage = "We have received too many requests from this device. Please try again in a few minutes."
                    case .userNotFound:
                        errorMessage = "Incorrect email and/or password."
                    case .networkError:
                        errorTitle = "Network Error"
                        errorMessage = "Please check your internet connection."
                    default:
                        errorMessage = error.localizedDescription
                    }
                    self.errorModel = ErrorModel(title: errorTitle, message: errorMessage)
                }
                return
            }
            let db = Firestore.firestore()
            let ref = db.collection("users").document(res.user.uid)
            ref.getDocument { (snapshot, error) in
                guard error == nil else {
                    print("ERROR GETTING DOCUMENTS: \(error)")
                    return
                }
                guard let snapshot = snapshot else {
                    print("Snapshot error: \(error)")
                    return
                }
                let result = Result {
                    try snapshot.data(as: User.self)
                }
                switch result {
                case .success(let user):
                    if let user = user {
                        userData.userID = user.id
                        userData.username = user.name
                        userData.email = user.email
                        if res.user.email != user.email {
                            firebaseManager.solveEmailAddressConflict(id: res.user.uid, email: res.user.email!) { errModel in
                                self.errorModel = errModel
                            }
                        }
                    }
                case .failure(let error):
                    print("Error decoding user: \(error)")
                }

            }
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}

