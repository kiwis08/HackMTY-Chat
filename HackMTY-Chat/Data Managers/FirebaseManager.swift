//
//  FirebaseManager.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Firebase
import SwiftUI
import UIKit

final class FirebaseManager: ObservableObject {
    
    func getProfilePicture(_ user: String, completion: @escaping (Image?, ErrorModel?) -> Void) {
        let storage = Storage.storage()
        let ref = storage.reference(withPath: "Profile pictures")
        
        ref.child(user).getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                ref.child("default.jpg").getData(maxSize: 1 * 1024 * 1024) { data, error in
                    let uiimage = UIImage(data: data!)
                    if let uiimage = uiimage {
                        let image = Image(uiImage: uiimage)
                        completion(image, nil)
                    } else {
                        completion(nil, ErrorModel(message: "Couldn't get image from data"))
                    }
                }
            } else {
                let uiimage = UIImage(data: data!)
                if let uiimage = uiimage {
                    let image = Image(uiImage: uiimage)
                    completion(image, nil)
                } else {
                    completion(nil, ErrorModel(message: "Couldn't get image from data"))
                }
            }
        }
    }
    
    func loadChats(currentUser: String, perform: @escaping ([Chat]) -> Void) {
        var chats: [Chat] = []
        let db = Firestore.firestore()
        let ref = db.collection("chats")
        let query = ref.whereField("users", arrayContains: currentUser)
        query.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error)
                return
            }
            snapshot.documentChanges.forEach({ change in
                    let result = Result {
                        try change.document.data(as: Chat.self)
                    }
                    switch result {
                    case .success(let chat):
                        if let chat = chat {
                            switch change.type {
                            case .added:
                                chats.append(chat)
                            case .modified:
                                chats.removeAll(where: { $0.id == chat.id })
                                chats.append(chat)
                            case .removed:
                                chats.removeAll(where: { $0.id == chat.id })
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
            })
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
    
    func getOtherUserName(from users: [String], currentUser: String, completion: @escaping (String) -> Void) {
        let otherUser = getOtherUser(from: users, currentUser: currentUser)
        getName(from: otherUser) { (name) in
            completion(name)
        }
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
    
    func joinChat(user: String, with secondUser: String, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("chats")
        let newChat = Chat(users: [user, secondUser])
        do {
            try ref.addDocument(from: newChat, encoder: .init()) { error in
                if let error = error {
                    completion(ErrorModel(message: error.localizedDescription))
                } else {
                    completion(nil)
                }
            }
        } catch {
            completion(ErrorModel(message: error.localizedDescription))
        }
    }
    
    func userExists(userID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").whereField("id", isEqualTo: userID)
        ref.getDocuments { snapshot, error in
            guard let snapshot = snapshot, snapshot.isEmpty == false else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func searchBySchool(currentUser: String, school schoolName: String, completion: @escaping ([User], ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").whereField("school.name", isEqualTo: schoolName).whereField("available", isEqualTo: true)
        var students = [User]()
        ref.getDocuments { snapshot, error in
            guard let snapshot = snapshot else {
                print(error?.localizedDescription)
                completion([], ErrorModel(message: error!.localizedDescription))
                return
            }
            guard snapshot.isEmpty == false else {
                completion([], nil)
                return
            }
            for document in snapshot.documents {
                let result = Result {
                    try document.data(as: User.self)
                }
                switch result {
                case .success(let user):
                    if let user = user {
                        students.append(user)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            students.removeAll(where: { $0.id == currentUser})
            completion(students, nil)
        }
    }
    
    func changeVisibility(_ user: String, available: Bool, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user)
        ref.setData(["available": available], merge: true) { error in
            if let error = error {
                completion(ErrorModel(message: error.localizedDescription))
            } else {
                completion(nil)
            }
        }
    }
    
    func getVisibility(_ user: String, completion: @escaping (Bool, ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user)
        ref.getDocument { snap, error in
            if let snap = snap {
                if let available = snap.data()?["available"] as? Bool {
                    completion(available, nil)
                } else {
                    completion(false, ErrorModel(message: "Unexpected error."))
                }
            } else {
                completion(false, ErrorModel(message: "Unexpected error."))
            }
        }
    }
    
    func changeSchool(_ user: String, to newSchool: School, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user)
        ref.setData(["school" : newSchool], merge: true)
    }
    
    func changeMajor(_ user: String, to newMajor: String, completion: @escaping (ErrorModel?) -> Void) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(user)
        ref.setData(["major" : newMajor], merge: true)
    }
}
