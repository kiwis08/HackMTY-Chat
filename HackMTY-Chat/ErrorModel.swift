//
//  ErrorModel.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import Foundation
struct ErrorModel: Identifiable {
    var id = UUID()
    var title: String
    var message: String
    
    init(message: String) {
        self.title = "Error"
        self.message = message
    }
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
