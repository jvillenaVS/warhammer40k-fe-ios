//
//  Equipment.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

struct Equipment: Codable, Identifiable {
    var id: String { name }
    var name: String
    var type: String
    var cost: Int
    var profile: Profile
}
