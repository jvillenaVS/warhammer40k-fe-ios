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
