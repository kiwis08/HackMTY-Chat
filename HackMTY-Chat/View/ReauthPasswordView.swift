//
//  ReauthPasswordView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI

struct ReauthPasswordView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var userSettings: UserData
    
    @Binding var show: Bool
    @Binding var successful: Bool
    
    @State private var password: String = ""
    
    @State private var errorModel: ErrorModel? = nil
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .font(.title2)
                    .padding([.top, .trailing])
                    .onTapGesture {
                        withAnimation {
                            self.show = false
                        }
                    }
            }
            Text("Re-enter your password")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Spacer()
                .frame(maxHeight: 30)
            LoginPasswordTextField(placeholder: "Password", text: $password)
                .padding(.horizontal)
            
            Button(action: {
                firebaseManager.reauthenticateUser(email: userSettings.email, password: password) { errorModel in
                    if let errorModel = errorModel {
                        self.errorModel = errorModel
                    } else {
                        print("Reauth successful")
                        self.successful = true
                        withAnimation {
                            self.show = false
                        }
                    }
                }
            }, label: {
                Text("Confirm")
            })
            .buttonStyle(BlueButton())
            .padding()
        }
        .frame(maxWidth: 370)
        .background(colorScheme == .light ? Color.white : Color.secondary)
        .cornerRadius(20)
        .shadow(radius: 10)
        .alert(item: $errorModel) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct ReauthPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ReauthPasswordView(show: .constant(true), successful: .constant(false))
    }
}

