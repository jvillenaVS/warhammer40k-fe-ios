//
//  FactionCodex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 6/7/25.
//

import FirebaseFirestore

struct FactionCodex: Identifiable, Codable {
    @DocumentID var id: String?  
    var name: String
    var iconUrl: String?
    var editionId: String?
    
    var docID: String {
        id ?? name.lowercased()
                 .replacingOccurrences(of: " ", with: "_")
    }
}

extension FactionCodex: Hashable {
    static func == (lhs: FactionCodex, rhs: FactionCodex) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
