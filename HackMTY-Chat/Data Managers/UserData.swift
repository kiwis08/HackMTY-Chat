//
//  UserSettings.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
final class UserData: ObservableObject {
    
    @AppStorage("userID") var userID: String = ""
    
    @AppStorage("username") var username: String = ""
    
    @AppStorage("email") var email: String = ""
    
    @AppStorage("school") var school: String = ""
    
    @AppStorage("country") var country: String = ""
    
    @AppStorage("major") var major: String = ""
    
    
    func resetToDefault() {
        userID = ""
        username = ""
        email = ""
        school = ""
        country = ""
        major = ""
    }
    
}
