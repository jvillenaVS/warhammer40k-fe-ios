//
//  LocalAvatarStore.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import UIKit

actor LocalAvatarStore {

    // Directorio base: <Caches>/Avatars/
    private let baseURL: URL = {
        let dir = try! FileManager.default.url(for: .cachesDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
            .appendingPathComponent("Avatars", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir,
                                                 withIntermediateDirectories: true)
        return dir
    }()

    // Ruta al archivo para un uid
    private func fileURL(for uid: String) -> URL {
        baseURL.appendingPathComponent("\(uid).jpg")
    }

    /// Guarda la imagen en JPEG (80 %)
    func save(_ image: UIImage, for uid: String) async throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw AvatarError.jpegEncodingFailed
        }
        try data.write(to: fileURL(for: uid), options: .atomic)
    }

    /// Devuelve la imagen si existe (nil si no hay archivo o hay error)
    func load(for uid: String) async -> UIImage? {
        let url = fileURL(for: uid)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return nil }
        return image
    }

    /// Devuelve la URL local *si existe*
    func localURL(for uid: String) async -> URL? {
        let url = fileURL(for: uid)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// Elimina el archivo local (ignora error “no existe”)
    func delete(for uid: String) async throws {
        let url = fileURL(for: uid)
        try? FileManager.default.removeItem(at: url)
    }
}

extension LocalAvatarStore {
    /// Carga la imagen desde disco de forma sincrónica.
    /// No requiere await; pensada para el arranque rápido.
    static func quickLoadSync(for uid: String) -> UIImage? {
        let caches = FileManager.default.urls(for: .cachesDirectory,
                                              in: .userDomainMask).first!
        let fileURL = caches
            .appendingPathComponent("Avatars", isDirectory: true)
            .appendingPathComponent("\(uid).jpg")
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data  = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        return image
    }
}
