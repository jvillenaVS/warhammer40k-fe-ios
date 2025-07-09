//
//  CodexSyncManager.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

//  CodexSyncManager.swift
//  Data ▸ Sync
import Foundation
import FirebaseFirestore

/// Implementación concreta del protocolo `SyncCodex`
final class CodexSyncManager: SyncCodex {
    
    // ───────────────────────── Singleton
    static let shared = CodexSyncManager()          // ←‑‑  AÑADE ESTA LÍNEA
    
    // ───────────────────────── Dependencias
    private let db    = Firestore.firestore()
    private let store: LocalCodexStore
    
    /// Init inyectable (por defecto usa un `LocalCodexStore` real)
    init(store: LocalCodexStore = try! LocalCodexStore()) {
        self.store = store
    }
    
    // MARK: – API pública (SyncCodex)
    /// Sincroniza las ediciones indicadas y devuelve las descargadas
    @discardableResult
    func syncAllCodexData(_ editions: [String]? = nil) async throws -> [String] {
        
        // 1. Resuelve las ediciones a bajar
        let editionIDs: [String]
        if let list = editions {
            editionIDs = list                          // inyectadas
        } else {
            editionIDs = try await fetchEditionIDs()   // dinámicas (Firestore)
        }
        
        // 2. Sincroniza en paralelo
        try await withThrowingTaskGroup(of: Void.self) { group in
            for id in editionIDs {
                group.addTask { try await self.syncEdition(id) }
            }
            try await group.waitForAll()
        }
        
        // 3. Devuelve las que se descargaron con éxito
        return editionIDs
    }
    
    // ───────────────────────── Implementación privada
    
    private func fetchEditionIDs() async throws -> [String] {
        try await withCheckedThrowingContinuation { cont in
            db.collection("editions").getDocuments { snap, err in
                if let err { cont.resume(throwing: err); return }
                let ids = snap?.documents.map(\.documentID) ?? []
                cont.resume(returning: ids)
            }
        }
    }
    
    /// Descarga factions, sub‑factions y detachments para una edición
    internal func syncEdition(_ edition: String) async throws {
        // 1. Factions
        let factions = try await fetchCollection(
            FactionCodex.self,
            path: "editions/\(edition)/factions")
        
        try await store.save(factions.map { $0.asRaw() },
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
    
    private func syncSubFactions(_ edition: String, _ fid: String) async throws {
        let subs = try await fetchCollection(
            SubFactionCodex.self,
            path: "editions/\(edition)/factions/\(fid)/subfactions")
        
        try await store.save(subs.map { $0.asRaw() },
                             at: "\(edition)/\(fid)/subfactions.json")
    }
    
    private func syncDetachments(_ edition: String, _ fid: String) async throws {
        let dets = try await fetchCollection(
            DetachmentCodex.self,
            path: "editions/\(edition)/factions/\(fid)/detachments")
        
        try await store.save(dets.map { $0.asRaw() },
                             at: "\(edition)/\(fid)/detachments.json")
    }
    
    // Helper genérico Firestore → array de modelos
    private func fetchCollection<T: Decodable>(
        _ type: T.Type, path: String) async throws -> [T] {
        
        try await withCheckedThrowingContinuation { cont in
            db.collection(path).getDocuments { snap, err in
                if let err { cont.resume(throwing: err); return }
                let docs = snap?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                cont.resume(returning: docs)
            }
        }
    }
}

