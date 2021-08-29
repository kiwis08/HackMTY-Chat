//
//  ProfilePictureView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 29/08/21.
//

import SwiftUI

struct ProfilePictureView: View {
    var image: Image
    var body: some View {
        image
            .resizable()
            .clipShape(Circle())
//            .shadow(radius: 10)
            .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 5))
            .frame(width: 100, height: 100, alignment: .center)
    }
}

//struct ProfilePictureView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfilePictureView()
//    }
//}
