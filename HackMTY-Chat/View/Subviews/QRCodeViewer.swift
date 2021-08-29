//
//  QRCodeViewer.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 29/08/21.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import AVFoundation

struct QRCodeViewer: View {
    var userID: String
    var body: some View {
        VStack {
            Text("Scan this to add me!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            Image(uiImage: generateCode(str: userID, type: .qr))
                .interpolation(.none)
                .resizable()
                .frame(width: 300, height: 300, alignment: .center)
        }
        .navigationBarTitle("My Code")
    }
    
    func generateCode(str: String, type: AVMetadataObject.ObjectType) -> UIImage {
        let context = CIContext()
        var filter = CIFilter()
        if type == .qr {
            filter = CIFilter.qrCodeGenerator()
        } else if type == .aztec {
            filter = CIFilter.aztecCodeGenerator()
        }
        let data = Data(str.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

//struct QRCodeViewer_Previews: PreviewProvider {
//    static var previews: some View {
//        QRCodeViewer()
//    }
//}
