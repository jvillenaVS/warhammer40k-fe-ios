//
//  SyncCodex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

//
//  SyncCodexUseCase.swift
//  WH40KBuilds – Domain
//
//  Define la operación que descarga y cachea los catálogos (Codex)
//  de Firestore a disco.  De este modo la capa de Presentación solo
//  depende de esta abstracción y no de la implementación concreta.
//

import Foundation

/// Use‑Case que sincroniza todos los datos de códex necesarios
/// (factions, sub‑factions, detachments, units, …) para una o más ediciones.
///
/// Implementaciones:
///   • `CodexSyncManager`      → descarga de Firestore  ➜  disco
///   • `MockCodexSyncManager`  → stub para tests / previews
///
public protocol SyncCodex {
    
    /// Sincroniza las ediciones indicadas o ‑si es nil‑
    /// *descubre* todas las que existan en `/editions`.
    @discardableResult
    func syncAllCodexData(_ editions: [String]?) async throws -> [String]
    
    /// (Opcional) sincroniza solo una edición concreta, por ejemplo "10e".
    /// Si no la necesitas puedes comentar este método.
    func syncEdition(_ edition: String) async throws
}
