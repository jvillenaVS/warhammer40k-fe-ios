//
//  PickerModifier.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct PickerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .pickerStyle(.menu)
            .foregroundColor(.white)
            .font(.inter(.medium, 14))
    }
}

extension View {
    func pickerStyle() -> some View {
        self.modifier(PickerModifier())
    }
}
