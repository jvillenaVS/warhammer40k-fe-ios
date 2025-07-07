//
//  SlotLimits.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 6/7/25.
//

struct SlotLimits: Codable {
    var hq:        MinMax
    var troops:    MinMax
    var elite:     MinMax
    var fastAttack: MinMax
    var heavySupport: MinMax
    var flyers:    MinMax
}
