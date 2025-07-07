//
//  RawDetachmentCodex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

struct RawDetachmentCodex: Codable, Identifiable {
    var id:   String?
    var name: String
    var cpCost: Int
    var limits: SlotLimits         
}
