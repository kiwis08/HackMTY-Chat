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
    var body: some View {
        NavigationView {
            List(chats) { chat in
                NavigationLink(
                    destination: ChatView(chat: chat, currentUser: userData.username),
                    label: {
                        Text(firebaseManager.getOtherUserName(from: chat.users, currentUser: userData.userID))
                    })
            }
            .navigationBarTitle("Chats")
        }
    }
}

//struct ChatsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatsListView()
//    }
//}
