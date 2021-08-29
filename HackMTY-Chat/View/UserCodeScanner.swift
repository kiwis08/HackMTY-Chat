//
//  UserCodeScanner.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import CodeScanner

struct UserCodeScanner: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var userData: UserData
    @State private var errorModel: ErrorModel? = nil
    var body: some View {
        CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, showViewfinder: true) { result in
            switch result {
            case .success(let userID):
                firebaseManager.userExists(userID: userID) { result in
                    switch result {
                    case true:
                        firebaseManager.joinChat(user: userData.userID, with: userID) { errModel in
                            if let errModel = errModel {
                                errorModel = errModel
                            } else {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    case false:
                        errorModel = ErrorModel(message: "Invalid user code.")
                    }
                }
            case .failure(let error):
                errorModel = ErrorModel(message: error.localizedDescription)
            }
        }
    }
}

struct UserCodeScanner_Previews: PreviewProvider {
    static var previews: some View {
        UserCodeScanner()
    }
}
