//
//  UnitCodex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 6/7/25.
//

struct UnitCodex: Identifiable, Codable {
    var id: String
    var name: String
    var type: String       
    var baseCost: Int
    var keywords: [String]
}
