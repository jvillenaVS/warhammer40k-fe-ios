//
//  SubFactionCodex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import FirebaseFirestore

struct SubFactionCodex: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    
    var docID: String {
        id ?? name.lowercased()
                 .replacingOccurrences(of: " ", with: "_")
    }
}

extension SubFactionCodex: Hashable {
    static func == (lhs: SubFactionCodex, rhs: SubFactionCodex) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
