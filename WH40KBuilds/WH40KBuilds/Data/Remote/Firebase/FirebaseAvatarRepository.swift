//
//  FirebaseAvatarRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import Combine
import FirebaseStorage
import FirebaseFirestore
import UIKit

final class FirebaseAvatarRepository: AvatarRepository {

    private let storage = Storage.storage().reference()
    private let cache   = LocalAvatarStore()

    // ▸ URL del avatar
    func fetchAvatar(for uid: String) async throws -> URL? {
        // 1⃣  Devolver inmediatamente el avatar cacheado
        if let local = await cache.localURL(for: uid) { return local }
        
        // 2⃣  Descargar de Storage y guardar en caché
        let remoteRef = storage.child("avatars/\(uid).jpg")
        let tmpURL    = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString + ".jpg")
        
        // 👉 API asíncrona correcta
        _ = try await remoteRef.writeAsync(toFile: tmpURL)
        
        // 3⃣  Persistir en disco de la app
        if let img = UIImage(contentsOfFile: tmpURL.path) {
            try await cache.save(img, for: uid)
        }
        try? FileManager.default.removeItem(at: tmpURL)   // limpia /tmp
        
        return await cache.localURL(for: uid)
    }

    // ▸ Subir imagen
    func uploadAvatar(_ image: UIImage, for uid: String) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw AvatarError.jpegEncodingFailed             
        }
        let ref = storage.child("avatars/\(uid).jpg")
        _ = try await ref.putDataAsync(data, metadata: nil)
        return try await ref.downloadURL()
    }

    // ▸ Borrar (opcional)
    func deleteAvatar(for uid: String) async throws {
        try await storage.child("avatars/\(uid).jpg").delete()
    }
}
