//
//  User.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Foundation
import FirebaseFirestoreSwift
struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
//    var currentUser: Bool
}
