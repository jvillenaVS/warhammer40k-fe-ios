//
//  MenuModifier.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import SwiftUI

struct MenuCubeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 200)
            .cornerRadius(12)
            .padding(.bottom, 85)
    }
}

extension View {
    func cubeStyle() -> some View {
        self.modifier(MenuCubeModifier())
    }
}
