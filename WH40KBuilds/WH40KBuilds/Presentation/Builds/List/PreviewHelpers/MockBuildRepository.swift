//
//  MockBuildRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

final class MockBuildRepository: BuildRepository {
    
    // Datos de ejemplo
    private let sampleBuilds: [Build] = [
        Build(
            id: "PREVIEW‑1",
            name: "Ultramarines Alpha",
            faction: .init(name: "Ultramarines", subfaction: "2nd Company"),
            detachmentType: "Battalion",
            commandPoints: 6,
            totalPoints: 2000,
            slots: .init(hq: 2, troops: 3, elite: 2, fastAttack: 1, heavySupport: 2, flyers: 0),
            units: [],
            stratagems: [],
            notes: "Preview Build A",
            createdBy: "PreviewUser",
            createdAt: Date()
        ),
        Build(
            id: "PREVIEW‑2",
            name: "Iron Hands Siege",
            faction: .init(name: "Iron Hands", subfaction: nil),
            detachmentType: "Patrol",
            commandPoints: 3,
            totalPoints: 1000,
            slots: .init(hq: 1, troops: 2, elite: 1, fastAttack: 0, heavySupport: 1, flyers: 0),
            units: [],
            stratagems: [],
            notes: nil,
            createdBy: "PreviewUser",
            createdAt: Date()
        )
    ]
    
    // MARK: - BuildRepository conformance
    func fetchBuilds() -> AnyPublisher<[Build], Error> {
        Just(sampleBuilds)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addBuild(_ build: Build) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateBuild(_ build: Build) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteBuild(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
