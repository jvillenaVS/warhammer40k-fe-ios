//
//  NeumorphicStyle.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import SwiftUI

struct NeumorphicStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.buildBackgroundColor)
                    .shadow(color: .black.opacity(configuration.isPressed ? 0 : 0.4),
                            radius: 6, x: 0, y: 4)
                    .shadow(color: .white.opacity(configuration.isPressed ? 0 : 0.08),
                            radius: 6, x: 0, y: -4)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
