//
//  View+Extensions.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 29/6/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

extension UIView {
    func snapshot() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { layer.render(in: $0.cgContext) }
    }
}

extension View {
    @ViewBuilder
    func validationMessage(_ msg: String?) -> some View {
        if let msg {
            VStack(alignment: .leading, spacing: 2) {
                self
                Text(msg)
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        } else {
            self
        }
    }
}
