//
//  UserProfileViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import SwiftUI
import Combine
import Foundation

@MainActor
final class UserProfileViewModel: ObservableObject {

    // ── Estado expuesto a la vista
    @Published var avatarUIImage: UIImage?          // única fuente para la UI
    @Published private(set) var avatarURL: URL?     // opcional (p.ej. para compartir)

    // ── Dependencias
    private let repo:  AvatarRepository
    private let uid:   String
    private let cache  = LocalAvatarStore()

    // ── Init
    init(repo: AvatarRepository = FirebaseAvatarRepository(),
         uid:  String) {
        self.repo = repo
        self.uid  = uid

        self.avatarUIImage = LocalAvatarStore.quickLoadSync(for: uid)
        Task { await loadCachedAndFetchFresh() }
    }

    // MARK: - Carga inicial
    /// 1) Carga la imagen local (si existe) → se ve al instante.
    /// 2) Lanza en paralelo la descarga remota; al llegar, actualiza UI + caché.
    private func loadCachedAndFetchFresh() async {
        // ① Local inmediata
        if let cached = await cache.load(for: uid) {
            avatarUIImage = cached
        }

        // ② Descarga remota en segundo plano
        Task {   // no ‘await’: se ejecuta en paralelo
            await self.reloadAvatar()
        }
    }

    // MARK: - Obtener la versión más reciente (con cache‑buster)
    func reloadAvatar() async {
        guard let url = try? await repo.fetchAvatar(for: uid) else { return }

        do {
            // — Cache‑buster para esquivar caché de CDN/URLSession
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            comps.queryItems = [URLQueryItem(name: "ts",
                                             value: "\(Date().timeIntervalSince1970)")]
            let freshURL = comps.url!

            let (data, _) = try await URLSession.shared.data(from: freshURL)
            guard let image = UIImage(data: data) else { return }

            // — ¿Realmente cambió?
            if avatarUIImage?.pngData() != image.pngData() {
                avatarUIImage = image            // UI inmediata
                try await cache.save(image, for: uid)
            }

            avatarURL = url                      // opcional, por si se necesita

        } catch {
            print("❌ Avatar download error:", error.localizedDescription)
        }
    }

    // MARK: - Subir nueva foto (desde Picker)
    func upload(image: UIImage) {
        Task {
            do {
                avatarUIImage = image
                try await cache.save(image, for: uid)          // se guarda local
                avatarURL = try await repo.uploadAvatar(image, for: uid) // sube
            } catch {
                print("❌ Avatar upload error:", error.localizedDescription)
            }
        }
    }

    // MARK: - Borrar avatar (opcional)
    func deleteAvatar() {
        Task {
            do {
                try await repo.deleteAvatar(for: uid)
                try await cache.delete(for: uid)
                avatarUIImage = nil
                avatarURL     = nil
            } catch {
                print("❌ Avatar delete error:", error.localizedDescription)
            }
        }
    }
}
