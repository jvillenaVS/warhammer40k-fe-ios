//
//  Build+Hashable.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 2/7/25.
//

import Foundation

extension Build: Hashable {
    
    // Igualdad: dos builds son el mismo si comparten documentID
    public static func == (lhs: Build, rhs: Build) -> Bool {
        lhs.id == rhs.id
    }
    
    // Hash: usa el documentID (opcional) como clave
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
