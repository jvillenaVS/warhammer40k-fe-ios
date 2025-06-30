//
//  MockBuildRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

final class MockBuildRepository: BuildRepository {
  
    var builds: [Build] = []
    
    private let addSampleBuilds: [Build] = [
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
        )
    ]
    
    func addMockBuild() {
        if let sample = addSampleBuilds.first {
            builds.append(sample)
        }
    }
    
    func fetchBuilds(for uid: String) -> AnyPublisher<[Build], any Error> {
        Just(addSampleBuilds)
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
