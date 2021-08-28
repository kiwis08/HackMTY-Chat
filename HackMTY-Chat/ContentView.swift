//
//  ContentView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @AppStorage("currentUserName") var currentUserName = ""
    @State var currentUser: User = User(id: UUID().uuidString, name: "TEST", email: "NOREALEMAIL")
    @State private var chats = [Chat]()
    @State private var showLogin = false
    @State private var isLoggedIn = false
    var body: some View {
        NavigationView {
            List(chats) { chat in
                NavigationLink(
                    destination: ChatView(chat: chat, currentUser: currentUser),
                    label: {
                        Text(getOtherUserName(from: chat.users, currentUser: currentUser.id))
                    })
            }
            .navigationBarTitle(currentUserName)
            .navigationBarItems(trailing:
                                    Button(action: {
                                        logout()
                                    }) {
                                        Text("Sign Out")
                                    })
            .sheet(isPresented: $showLogin, content: {
                LoginView()
                    .onDisappear() {
                        checkAuth()
                    }
            })
            .onAppear {
                checkAuth()
            }
        }
    }
    func logout() {
        do {
            try Auth.auth().signOut()
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func checkAuth() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user == nil else {
                showLogin = false
                isLoggedIn = true
                print("Running this")
                if let current = UserDefaults.standard.object(forKey: "currentUser") as? Data {
                    if let decodedUser = try? JSONDecoder().decode(User.self, from: current) {
                        self.currentUser = decodedUser
                        self.currentUserName = decodedUser.name
                    }
                }
                loadChats { chats in
                    self.chats = chats
                }
                return
            }
            showLogin = true
        }
    }
    
    func loadChats(perform: @escaping ([Chat]) -> Void) {
        var chats: [Chat] = []
        let db = Firestore.firestore()
        let ref = db.collection("chats")
        let query = ref.whereField("users", arrayContains: currentUser.id)
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
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
