//
//  CodingKeys.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation

enum CodingKeys: String, CodingKey {
    case range
    case type
    case strength = "S"
    case armourPenetration = "AP"
    case damage = "D"
}
