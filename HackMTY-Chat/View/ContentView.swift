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
    @StateObject var firebaseManager = FirebaseManager()
    @StateObject var userData = UserData()
    @State private var chats = [Chat]()
    @State private var checkedAuth = false
    @State private var loggedIn = false
    @State private var showCodeAddSheet = false
    @State private var showAddBySchoolSheet = false
    
    @State private var selectedTab = Tabs.chats
    
    @State private var errorModel: ErrorModel?
    
    enum Tabs: String {
        case chats = "chats"
        case scan = "scanner"
        case settings = "settings"
    }
    
    var body: some View {
        ZStack {
            if checkedAuth {
                if loggedIn {
                    NavigationView {
                        TabView(selection: $selectedTab) {
                            ChatsListView(chats: $chats)
                                .environmentObject(firebaseManager)
                                .environmentObject(userData)
                                .tabItem {
                                    Image(systemName: "message.fill")
                                    Text("Chats")
                                }
                                .tag(Tabs.chats)
                            SettingsView()
                                .environmentObject(firebaseManager)
                                .environmentObject(userData)
                                .tabItem {
                                    Image(systemName: "gear")
                                    Text("Settings")
                                }
                                .tag(Tabs.settings)
                        }
                        .navigationBarTitle(selectedTab == .chats ? "Chats" : "Settings")
                        .toolbar(content: {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                if selectedTab == .chats {
                                    Menu {
                                        Button(action: {
                                            showCodeAddSheet = true
                                        }, label: {
                                            Label("Scan QR code", systemImage: "qrcode.viewfinder")
                                        })
                                        Button(action: {
                                            showAddBySchoolSheet = true
                                        }, label: {
                                            Label("Search school", systemImage: "magnifyingglass")
                                        })
                                    } label: {
                                        Text("Looking for a friend?")
                                    }
                                }
                            }
                        })
                        .sheet(isPresented: $showCodeAddSheet, onDismiss: {
                            firebaseManager.loadChats(currentUser: userData.userID) { chats in
                                self.chats = chats
                            }
                        }, content: {
                            UserCodeScanner()
                                .environmentObject(firebaseManager)
                                .environmentObject(userData)
                        })
                        .sheet(isPresented: $showAddBySchoolSheet, onDismiss: {
                            firebaseManager.loadChats(currentUser: userData.userID) { chats in
                                self.chats = chats
                            }
                        }, content: {
                            SchoolMembersList(school: userData.school)
                                .environmentObject(firebaseManager)
                                .environmentObject(userData)
                        })
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                } else {
                    LoginView(errorModel: $errorModel)
                        .environmentObject(firebaseManager)
                        .environmentObject(userData)
                }
            }
        }
        .onAppear {
            checkAuth()
        }
    }
    
    
    func checkAuth() {
        Auth.auth().currentUser?.reload(completion: { error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
        })
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                loadUserData(uid: user.uid, email: user.email!)
                firebaseManager.loadChats(currentUser: user.uid) { chats in
                    self.chats = chats
                }
                return
            } else {
                loggedIn = false
                checkedAuth = true
            }
        }
    }
    
    func loadUserData(uid: String, email: String) {
        let db = Firestore.firestore()
        let ref = db.collection("users").document(uid)
        ref.getDocument { snapshot, error in
            guard let document = snapshot else {
                print("Error getting user document: \(error!)")
                return
            }
            
            let result = Result {
                try document.data(as: User.self)
            }
            switch result {
            case .success(let user):
                if let user = user {
                    userData.userID = user.id
                    userData.username = user.name
                    userData.email = email
                    userData.school = user.school.name
                    userData.country = user.country
                    userData.major = user.major
                    if email != user.email {
                        firebaseManager.solveEmailAddressConflict(id: user.id, email: email) { errModel in
                            self.errorModel = errModel
                        }
                    }
                    withAnimation {
                        loggedIn = true
                        checkedAuth = true
                    }
                }
            case .failure(let error):
                print("Error decoding user: \(error)")
            }
            
        }
    }
    
    
    
    
    
   
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
