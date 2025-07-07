//
//  Untitled.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 6/7/25.
//

import FirebaseFirestore

struct DetachmentCodex: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var cpCost: Int
    var limits: SlotLimits
    
    var docID: String {
        id ?? name.lowercased()
                 .replacingOccurrences(of: " ", with: "_")
    }
}

extension DetachmentCodex: Hashable {
    static func == (lhs: DetachmentCodex, rhs: DetachmentCodex) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
