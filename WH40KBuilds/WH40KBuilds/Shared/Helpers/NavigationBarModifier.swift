//
//  NavigationBarModifier.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 3/7/25.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var titleColor: UIColor

    init(backgroundColor: Color, titleColor: Color = .white) {
        self.backgroundColor = UIColor(backgroundColor)
        self.titleColor = UIColor(titleColor)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = self.backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: self.titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: self.titleColor]
        
        let clearAppearance = UINavigationBarAppearance()
        clearAppearance.configureWithTransparentBackground()
        clearAppearance.backgroundColor = .clear
        clearAppearance.titleTextAttributes = [.foregroundColor: self.titleColor]
        clearAppearance.largeTitleTextAttributes = [.foregroundColor: self.titleColor]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = clearAppearance
    }

    func body(content: Content) -> some View {
        content
    }
}
