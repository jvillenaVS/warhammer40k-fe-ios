//
//  Slots.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

struct Slots: Codable {
    var hq: Int
    var troops: Int
    var elite: Int
    var fastAttack: Int
    var heavySupport: Int
    var flyers: Int
    
    enum CodingKeys: String, CodingKey {
        case hq = "HQ"
        case troops, elite, fastAttack, heavySupport, flyers
    }
}
