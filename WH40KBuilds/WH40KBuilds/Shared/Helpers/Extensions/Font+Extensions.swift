//
//  Font+Extensions.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 30/6/25.
//

import SwiftUI

/// Variantes disponibles de la familia Inter.
enum InterFont: String {
    case regular   = "Inter-Regular"
    case light     = "Inter-Light"
    case medium    = "Inter-Medium"
    case semiBold  = "Inter-SemiBold"
    case bold      = "Inter-Bold"
}

/// Extiende `Font` para exponer `.inter(_,_)`
extension Font {
    
    /// Fuente Inter con tamaño fijo.
    static func inter(_ style: InterFont, _ size: CGFloat) -> Font {
        .custom(style.rawValue, size: size)
    }
    
    /// Fuente Inter que **respeta Dynamic Type** (opcional).
    /// Ej.: `.font(.inter(.regular, textStyle: .body))`
    static func inter(_ style: InterFont,
                      textStyle: Font.TextStyle,
                      relativeTo base: Font.TextStyle = .body) -> Font {
        .custom(style.rawValue,
                size: UIFont.preferredFont(forTextStyle: textStyle.toUIFontTextStyle).pointSize,
                relativeTo: base)
    }
}

private extension Font.TextStyle {
    /// Mapea `Font.TextStyle` a `UIFont.TextStyle`
    var toUIFontTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title:      return .title1
        case .title2:     return .title2
        case .title3:     return .title3
        case .headline:   return .headline
        case .subheadline:return .subheadline
        case .body:       return .body
        case .callout:    return .callout
        case .footnote:   return .footnote
        case .caption:    return .caption1
        case .caption2:   return .caption2
        default:          return .body
        }
    }
}

/* How to use them
 * *********************************************
 Text("Builds")
     .font(.inter(.semiBold, 24))

 Text("Descripción")
     .font(.inter(.regular, textStyle: .body))
 * *********************************************
 */
