//
//  UIWindow.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 9/7/25.
//

import UIKit   

extension UIWindow {
    /// Renderiza la ventana actual en un `UIImage`.
    func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}
