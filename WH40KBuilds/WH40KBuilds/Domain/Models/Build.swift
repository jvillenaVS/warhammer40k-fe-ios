//
//  Build.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
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
