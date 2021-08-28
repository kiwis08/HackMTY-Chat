//
//
//  ChatView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//


import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ChatView: View {
    @State var chat: Chat
    @State private var messages: [Message] = []
    var currentUser: String
    @State private var messageField = ""
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    LazyVStack {
                        ForEach(messages) { message in
                            MessageCell(message: message, currentUser: currentUser)
                        }
                    }
                    .onChange(of: messages, perform: { value in
                        if messages.last?.sentBy == currentUser {
                            withAnimation {
                                scrollView.scrollTo(messages.last!.id, anchor: .bottom)
                            }
                        }
                    })
                }
            }
            HStack {
                TextField("Enter message", text: self.$messageField)
                    .font(.custom("Montserrat", size: 15))
                    .padding()
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                Spacer()
                Image(systemName: "paperplane.fill")
                    .foregroundColor(Color.gray.opacity(1))
                    .padding(.trailing, 15)
                    .onTapGesture{
                        guard self.messageField.isEmpty == false else {
                            return
                        }
                        let message = Message(text: messageField, sentBy: currentUser, date: Date())
                        sendMessage(message: message, to: chat)
                        messageField = ""
                        
                    }
                
                
                
            }
            .padding()
        }
        .navigationBarTitle(Text("Username"), displayMode: .inline)
        .onAppear() {
            loadMessages()
        }
    }
    
    
    
    func loadMessages() {
        let db = Firestore.firestore()
        let ref = db.collection("chats/\(chat.id!)/messages").order(by: "date")
        ref.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else {
                print(error)
                return
            }
            var messages: [Message] = []
            for document in snapshot.documents {
                let result = Result {
                    try document.data(as: Message.self)
                }
                
                switch result {
                case .success(let message):
                    if let message = message {
                        messages.append(message)
                    }
                case .failure(let error):
                    print(error)
                }
                
            }
            self.messages = messages
        }
    }
    
    
    func sendMessage(message: Message, to chat: Chat) {
        let db = Firestore.firestore()
        let docID = UUID().uuidString
        let ref = db.collection("chats/\(chat.id!)/messages").document(docID)
        do {
            try ref.setData(from: message)
        } catch {
            print(error)
        }
    }
    
    
}
