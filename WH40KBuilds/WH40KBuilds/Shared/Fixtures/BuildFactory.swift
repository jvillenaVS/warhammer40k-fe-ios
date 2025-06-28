//
//  BuildFactory.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation

struct BuildFactory {
    static func sampleBuild() -> Build {
        return Build(
            id: nil,
            name: "Orkos",
            faction: .init(name: "Orkos", subfaction: "Kuerpo Zibernétiko"),
//            name: "Ultramarines Alpha",
//            faction: .init(name: "Ultramarines", subfaction: "2nd Company"),
            detachmentType: "Battalion",
            commandPoints: 7,
            totalPoints: 1500,
            slots: .init(hq: 3, troops: 4, elite: 2, fastAttack: 1, heavySupport: 4, flyers: 0),
            units: [],
            stratagems: [],
            notes: "Second sample build",
            createdBy: "josevil",
            createdAt: Date()
        )
    }
}
