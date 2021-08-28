//
//  Message.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Foundation
import FirebaseFirestoreSwift
struct Message: Codable, Identifiable, Equatable {
    @DocumentID var id: String? = UUID().uuidString
    var text: String
    var sentBy: String
    var date: Date
}
