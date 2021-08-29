//
//  ChatsListView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI

struct ChatsListView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var userData: UserData
    @Binding var chats: [Chat]
    @State private var names: [String : String] = [:]
    
    var body: some View {
        List(chats) { chat in
            NavigationLink(
                destination: ChatView(chat: chat, currentUser: userData.username),
                label: {
                    Text(names[chat.id!] ?? "")
                })
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            for chat in chats {
                firebaseManager.getOtherUserName(from: chat.users, currentUser: userData.userID) { name in
                    names[chat.id!] = name
                }
            }
        }
    }
}

//struct ChatsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatsListView()
//    }
//}
