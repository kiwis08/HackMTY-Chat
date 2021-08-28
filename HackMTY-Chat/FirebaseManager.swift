//
//  FirebaseManager.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Firebase

final class FirebaseManager: ObservableObject {
    
    func loadChats(currentUser: String, perform: @escaping ([Chat]) -> Void) {
        var chats: [Chat] = []
        let db = Firestore.firestore()
        let ref = db.collection("chats")
        let query = ref.whereField("users", arrayContains: currentUser)
        query.getDocuments { (snapshot, error) in
            guard error == nil else {
                print(error)
                return
            }
            print("Chat snapshot has: \(snapshot?.count) documents")
            for document in snapshot!.documents {
                let result = Result {
                    try document.data(as: Chat.self)
                }
                switch result {
                case .success(let chat):
                    if let chat = chat {
                        chats.append(chat)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            perform(chats)
        }
    }
    
    func getName(from id: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(id)
        ref.getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error)
                return
            }
            let name = snapshot.data()?["name"] as! String
            completion(name)
            //            let result = Result {
            //                try snapshot.data(as: User.self)
            //            }
            //
            //            switch result {
            //            case .success(let user):
            //                if let user = user {
            //                    name = user.name
            //                    print("Name setted")
            //                }
            //            case .failure(let error):
            //                print(error)
            //            }
        }
    }
    
    func getOtherUser(from users: [String], currentUser: String) -> String {
        var userID = ""
        for user in users {
            if user != currentUser {
                userID = user
            }
        }
        return userID
    }
    
    func getOtherUserName(from users: [String], currentUser: String) -> String {
        var username = "Username"
        let otherUser = getOtherUser(from: users, currentUser: currentUser)
        getName(from: otherUser) { (name) in
            username = name
        }
        return username
    }
    
    func signOut(completion: (ErrorModel?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            print("Error signing out: \(error)")
            completion(ErrorModel(message: error.localizedDescription))
        }
    }
    
    func solveEmailAddressConflict(id: String, email: String, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(id)
        ref.updateData(["email": email]) { err in
            if err != nil {
                completion(ErrorModel(message: "There's a problem with your email address, please contact and administrator."))
            } else {
                completion(nil)
            }
        }
    }
    
    func changeEmailAddress(email: String, id: String, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(id)
        let user = Auth.auth().currentUser
        user?.updateEmail(to: email) { error in
            if let error = error {
                completion(ErrorModel(message: error.localizedDescription))
            } else {
                ref.updateData(["email": email]) { err in
                    if let err = err {
                        completion(ErrorModel(message: "\(err.localizedDescription)\n Please contact an administrator."))
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func changeUsername(newName: String, id: String, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(id)
        ref.updateData(["name": newName]) { err in
            if let err = err {
                completion(ErrorModel(message: "\(err.localizedDescription)\n Please contact an administrator."))
            } else {
                completion(nil)
            }
        }
    }
    
    func reauthenticateUser(email: String, password: String, completion: @escaping (ErrorModel?) -> Void) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential, completion: { dataResult, error in
            if let error = error {
                completion(ErrorModel(message: error.localizedDescription))
            } else {
                completion(nil)
                print("Reauthenticated")
            }
        })
    }
}
