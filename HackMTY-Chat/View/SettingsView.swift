//
//  SettingsView.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI
import Firebase
import CoreImage.CIFilterBuiltins
import AVFoundation

fileprivate enum ViewSettings: String {
    case email = "My Email Address"
    case name = "My Username"
}

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var userSettings: UserData
    
    @State private var showBuild = false
    
    @State private var errorModel: ErrorModel? = nil
    
    var appVersion: String {
        guard let versionNumber = UIApplication.appVersionNumber, let buildNumber = UIApplication.appBuildNumber else { return ""}
        return showBuild ? "\(versionNumber) (\(buildNumber))" : versionNumber
    }
    var body: some View {
        VStack {
            List {
                Section {
                    NavigationLink(destination: ChangeSettingsSubView(settings: .name).environmentObject(firebaseManager).environmentObject(userSettings)) {
                        Image(systemName: "person.fill")
                        Text("My username")
                    }
                    NavigationLink(destination: ChangeSettingsSubView(settings: .email).environmentObject(firebaseManager).environmentObject(userSettings)) {
                        Image(systemName: "envelope")
                        Text("My Email Address")
                    }
                }
                
                Section {
                    NavigationLink(
                        destination: Image(uiImage: generateCode(str: userSettings.userID, type: .qr)).interpolation(.none).resizable().frame(width: 300, height: 300, alignment: .center),
                        label: {
                            Text("My QR Code")
                        })
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        showBuild.toggle()
                    }
                }
                Button(action: {
                    firebaseManager.signOut { errorModel in
                        if let errorModel = errorModel {
                            self.errorModel = errorModel
                        } else {
                            userSettings.resetToDefault()
                        }
                    }
                }, label: {
                    Text("Sign out")
                })
                .buttonStyle(BlueButton())
                .listRowBackground(Color(UIColor.systemGroupedBackground))
                .animation(.none)
            }.listStyle(InsetGroupedListStyle())
        }
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

struct ChangeSettingsSubView: View {
    @EnvironmentObject var firebaseSettings: FirebaseManager
    @EnvironmentObject var userSettings: UserData
    fileprivate var settings: ViewSettings
    @State private var setting = ""
    
    @State private var showReauthView = false
    @State private var reauthenticated = false
    
    @State private var errorModel: ErrorModel? = nil
    
    var body: some View {
        ZStack {
            VStack {
                LoginEmailTextField(placeholder: settings.rawValue, text: $setting)
                    .padding(.top, 30)
                    .padding(.horizontal)
                
                Button(action: {
                    withAnimation {
                        showReauthView = true
                    }
                }, label: {
                    Text("Change \(settings.rawValue)")
                })
                .buttonStyle(BlueButton())
                .padding(.horizontal)
                Spacer()
            }
            .navigationBarTitle(Text(settings.rawValue), displayMode: .inline)
            .blur(radius: showReauthView ? 8 : 0)
            .disabled(showReauthView)
            
            if showReauthView {
                ReauthPasswordView(show: $showReauthView, successful: $reauthenticated)
                    .environmentObject(firebaseSettings)
                    .environmentObject(userSettings)
                    .transition(.move(edge: .bottom))
                    .onDisappear {
                        if reauthenticated {
                            switch settings {
                            case .email:
                                firebaseSettings.changeEmailAddress(email: setting, id: userSettings.userID) { errModel in
                                    if errModel == nil {
                                        userSettings.email = setting
                                    }
                                    self.errorModel = errModel
                                }
                            case .name:
                                firebaseSettings.changeUsername(newName: setting, id: userSettings.userID) { errModel in
                                    if errModel == nil {
                                        userSettings.username = setting
                                    }
                                    self.errorModel = errModel
                                }
                            }
                        }
                    }
            }
        }
        .alert(item: $errorModel) {
            Alert(title: Text($0.title), message: Text($0.message), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            switch settings {
            case .email:
                self.setting = userSettings.email
            case .name:
                self.setting = userSettings.username
            }
        }
        
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//            .environmentObject(FirebaseSettingsManager())
//            .environmentObject(UserSettings())
//            .preferredColorScheme(.light)
//    }
//}
