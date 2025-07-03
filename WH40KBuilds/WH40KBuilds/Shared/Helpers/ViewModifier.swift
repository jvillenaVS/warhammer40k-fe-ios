//
//  ViewModifier.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 2/7/25.
//

import SwiftUI

struct AppBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.appBg.ignoresSafeArea()
            content
        }
    }
}

extension View {
    func withAppBackground() -> some View {
        self.modifier(AppBackgroundModifier())
    }
}
