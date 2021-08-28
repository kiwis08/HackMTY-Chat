//
//  UIApplication+AppVersion.swift
//  HackMTY-Chat
//
//  Created by Santiago Quihui on 28/08/21.
//

import SwiftUI

extension UIApplication {
    static var appVersionNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var appBuildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
    static var appName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
