//
//  Profile.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation

struct Profile: Codable {
    var range: String
    var type: String
    var strength: StringOrInt
    var armourPenetration: StringOrInt
    var damage: StringOrInt
}
