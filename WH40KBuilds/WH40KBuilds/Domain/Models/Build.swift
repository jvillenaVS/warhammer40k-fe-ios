//
//  Build.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import FirebaseFirestore

struct Build: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var faction: Faction
    var detachmentType: String
    var commandPoints: Int
    var totalPoints: Int
    var slots: Slots
    var units: [Unit]
    var stratagems: [Stratagem]
    var notes: String?
    var createdBy: String
    var createdAt: Date
}

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
