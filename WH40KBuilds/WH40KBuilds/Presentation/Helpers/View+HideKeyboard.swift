//
//  View+HideKeyboard.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 29/6/25.
//

import SwiftUI

extension View {
    /// Cierra el teclado activo
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
