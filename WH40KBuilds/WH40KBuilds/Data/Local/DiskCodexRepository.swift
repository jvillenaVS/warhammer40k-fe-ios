//
//  DiskCodexRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import Combine

struct DiskCodexRepository: CodexRepository {
    
    /// Instancia inyectada del store (por defecto la compartida)
    private let store: LocalCodexStore
    
    init(store: LocalCodexStore = try! LocalCodexStore()) {
        self.store = store
    }
    
    // ───────── Factions ─────────
    func factions(edition: String) -> AnyPublisher<[FactionCodex], Error> {
        load([RawFactionCodex].self, at: "\(edition)/factions.json")
            .map { $0.map(FactionCodex.init(raw:)) }
            .eraseToAnyPublisher()
    }
    
    // ───────── Sub‑Factions ─────
    func subFactions(edition: String,
                     faction: String) -> AnyPublisher<[SubFactionCodex], Error> {
        load([RawSubFactionCodex].self,
             at: "\(edition)/\(faction)/subfactions.json")
            .map { $0.map(SubFactionCodex.init(raw:)) }
            .eraseToAnyPublisher()
    }
    
    // ───────── Detachments ──────
    func detachments(edition: String,
                     faction: String) -> AnyPublisher<[DetachmentCodex], Error> {
        load([RawDetachmentCodex].self,
             at: "\(edition)/\(faction)/detachments.json")
            .map { $0.map(DetachmentCodex.init(raw:)) }
            .eraseToAnyPublisher()
    }
    
    // MARK: – Helper genérico (con await)
    private func load<T: Decodable>(_ type: T.Type,
                                    at path: String)
    -> AnyPublisher<T, Error> {
        Future { promise in
            Task {
                do {
                    let value = try await store.load(type, from: path)
                    promise(.success(value))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

