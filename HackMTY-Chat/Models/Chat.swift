//
//  Chat.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var users: [String]
}
