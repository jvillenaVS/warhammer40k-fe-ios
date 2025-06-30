//
//  Stratagem.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

struct Stratagem: Codable, Identifiable {
    var id: String { name }
    var name: String
    var costCP: Int
    var description: String
}
