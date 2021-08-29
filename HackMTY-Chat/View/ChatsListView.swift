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
    @Binding var names: [String : String]
    @Binding var profilePictures: [String : Image]
    
    var body: some View {
        VStack {
            if chats.isEmpty {
                Spacer()
                Text("Wow... such empty. Look for new friends on the top right corner!")
                    .font(.system(size: 32))
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                Spacer()
            } else {
                List(chats) { chat in
                    NavigationLink(
                        destination: ChatView(chat: chat, currentUser: userData.username, otherUser: $names[chat.id!]),
                        label: {
                            HStack {
                                if profilePictures[chat.id!] != nil {
                                    profilePictures[chat.id!]?
                                        .resizable()
                                        .clipShape(Circle())
                                        .frame(width: 50, height: 50)
                                        .scaledToFit()
                                } else {
                                    ProgressView("")
                                        .frame(width: 50, height: 50)
                                        .progressViewStyle(CircularProgressViewStyle())
                                }
                                Text(names[chat.id!] ?? "")
                            }
                        })
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .onAppear {
            for chat in chats {
                firebaseManager.getOtherUserName(from: chat.users, currentUser: userData.userID) { name in
                    names[chat.id!] = name
                }
                let friendUserID = firebaseManager.getOtherUser(from: chat.users, currentUser: userData.userID)
                firebaseManager.getProfilePicture(friendUserID)  { image, errModel in
                    profilePictures[chat.id!] = image!
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
