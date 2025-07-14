//
//  EditionCodex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 14/7/25.
//

import FirebaseFirestore

struct EditionCodex: Identifiable, Codable {
    @DocumentID var id: String?
    
    var name: String {
        id ?? "unknown"
    }
}

extension EditionCodex: Hashable {
    static func == (lhs: EditionCodex, rhs: EditionCodex) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
