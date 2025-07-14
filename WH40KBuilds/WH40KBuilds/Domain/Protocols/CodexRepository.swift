//
//  CodexRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 6/7/25.
//

import Combine

protocol CodexRepository {
    func editions() -> AnyPublisher<[EditionCodex], Error>
    func factions(edition: String) -> AnyPublisher<[FactionCodex], Error>
    func subFactions(edition: String, faction: String) -> AnyPublisher<[SubFactionCodex], Error>
    func detachments(edition: String, faction: String) -> AnyPublisher<[DetachmentCodex], Error>
}
