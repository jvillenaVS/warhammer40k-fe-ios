//
//  Unit.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

struct Unit: Codable, Identifiable {
    var id: String         
    var name: String
    var type: String
    var keywords: [String]
    var stats: Stats
    var modelsCount: Int
    var baseCost: Int
    var equipment: [Equipment]
    var wargearOptions: [String]
    var abilities: [String]
    var unitTotalCost: Int
}
