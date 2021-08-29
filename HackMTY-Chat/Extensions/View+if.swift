//
//  View+if.swift
//  View+if
//
//  Created by Santiago Quihui on 29/08/21.
//

import SwiftUI

extension View {
    /// Closure given view if conditional.
    /// - Parameters:
    ///   - conditional: Boolean condition.
    ///   - content: Closure to run on view.
    @ViewBuilder func `if`<Content: View>(_ conditional: Bool = true, @ViewBuilder _ content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}
