//
//  MessageCell.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI

struct MessageCell: View {
    var message: Message
    var currentUser: String
    var isCurrentUser: Bool {
        message.sentBy == currentUser
    }
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            Text(message.text)
                .padding(10)
                .foregroundColor(.white)
                .background(isCurrentUser ? Color.blue : Color.gray)
                .cornerRadius(10)
                .padding(3)
            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

//struct MessageCell_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageCell(message: Message(text: "Message", sentByCurrentUser: true, date: Date()))
//    }
//}
