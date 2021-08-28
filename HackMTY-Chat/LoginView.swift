//
//  LoginView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    let userdefaults = UserDefaults.standard
    
    
    var body: some View {
            VStack {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .padding(.top, 20)
                Spacer()
                TextField("Email", text: $email)
                    .textFieldStyle(CustomTextField())
                SecureField("Password", text: $password) {
                    login()
                }
                .textFieldStyle(CustomTextField())
                
                Button(action: {
                    login()
                }, label: {
                    Text("Sign in")
                })
                .buttonStyle(BlueButton())
            }
            .padding(.horizontal, 50)
    }
    
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard error == nil else {
                print("Error logging in: \(error?.localizedDescription)")
                return
            }
            let db = Firestore.firestore()
            let ref = db.collection("users")
            let query = ref.whereField("email", isEqualTo: email.lowercased())
            query.getDocuments { (snapshot, error) in
                guard error == nil else {
                    print("ERROR GETTING DOCUMENTS: \(error)")
                    return
                }
                guard let snapshot = snapshot else {
                    print("Snapshot error: \(error)")
                    return
                }
                for document in snapshot.documents {
                    let doc = document
                    var user: User? = User(id: "", name: "", email: "")
                    do {
                        user = try doc.data(as: User.self)
                    } catch {
                        print("Error with doc data: \(error)")
                    }
                    do {
                        let encodedUser = try JSONEncoder().encode(user)
                        userdefaults.set(encodedUser, forKey: "currentUser")
                    } catch {
                        print(error)
                    }
                }

            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

