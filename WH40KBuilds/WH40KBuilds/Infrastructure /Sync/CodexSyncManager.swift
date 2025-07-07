//
//  CodexSyncManager.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import FirebaseFirestore

/// Implementa el caso de uso `SyncCodexUseCase`
final class CodexSyncManager: SyncCodex {
    
    // MARK: – DEPENDENCIAS
    private let db    = Firestore.firestore()
    private let store: LocalCodexStore          // actor inyectado
    
    // Inyección por defecto
    init(store: LocalCodexStore = try! LocalCodexStore()) {
        self.store = store
    }
    
    // MARK: – API pública
    /// Descarga todas las colecciones necesarias de la edición y las cachea en disco
    func syncAllCodexData() async throws {
        try await syncEdition("10e")
    }
    
    // MARK: – Interno --------------------------------------------------------
    internal func syncEdition(_ edition: String) async throws {
        // 1. Factions
        let factions = try await fetchCollection(FactionCodex.self,
                         path: "editions/\(edition)/factions")
        try await store.save(
            factions.map { $0.asRaw() },
            at: "\(edition)/factions.json")
        
        // 2. Sub‑colecciones en paralelo
        try await withThrowingTaskGroup(of: Void.self) { group in
            for faction in factions {
                guard let fid = faction.id else { continue }
                group.addTask { try await self.syncSubFactions(edition, fid) }
                group.addTask { try await self.syncDetachments(edition, fid) }
            }
            try await group.waitForAll()
        }
    }
    
    private func syncSubFactions(_ edition: String,
                                 _ fid: String) async throws {
        let subs = try await fetchCollection(SubFactionCodex.self,
                     path: "editions/\(edition)/factions/\(fid)/subfactions")
        try await store.save(
            subs.map { $0.asRaw() },
            at: "\(edition)/\(fid)/subfactions.json")
    }
    
    private func syncDetachments(_ edition: String,
                                 _ fid: String) async throws {
        let dets = try await fetchCollection(DetachmentCodex.self,
                     path: "editions/\(edition)/factions/\(fid)/detachments")
        try await store.save(
            dets.map { $0.asRaw() },
            at: "\(edition)/\(fid)/detachments.json")
    }
    
    // MARK: – Helper genérico Firestore → [T]
    private func fetchCollection<T: Decodable>(_ type: T.Type,
                                               path: String) async throws -> [T] {
        try await withCheckedThrowingContinuation { cont in
            db.collection(path).getDocuments { snap, err in
                if let err { cont.resume(throwing: err); return }
                let docs = snap?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                cont.resume(returning: docs)
            }
        }
    }
}

