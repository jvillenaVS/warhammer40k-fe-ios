//
//  LocalCodexStore.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import Foundation

actor LocalCodexStore {
    
    // MARK: – Init (permite inyectar ruta distinta en tests)
    init(root: URL? = nil) throws {
        if let custom = root {
            rootURL = custom
        } else {
            rootURL = try Self.defaultRoot()
        }
    }
    
    // MARK: – API pública ----------------------------------------------------
    
    /// Guarda cualquier Encodable como JSON
    func save<T: Encodable>(_ value: T, at path: String) throws {
        let url  = try makeURL(for: path)
        let data = try JSONEncoder().encode(value)
        try write(data: data, to: url)
    }
    
    /// Versión “Data” (p. ej. diccionario codificado por Firestore.Encoder)
    func saveData(_ data: Data, at path: String) throws {
        let url = try makeURL(for: path)
        try write(data: data, to: url)
    }
    
    /// Carga y decodifica JSON
    func load<T: Decodable>(_ type: T.Type,
                            from path: String) throws -> T {
        let url  = rootURL.appendingPathComponent(path)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// ¿Existe el archivo?
    func fileExists(at path: String) -> Bool {
        FileManager.default.fileExists(
            atPath: rootURL.appendingPathComponent(path).path)
    }
    
    // MARK: – Interno --------------------------------------------------------
    
    private let rootURL: URL
    
    private static func defaultRoot() throws -> URL {
        let base = FileManager.default.urls(for: .libraryDirectory,
                                            in: .userDomainMask)[0]
        let url  = base.appendingPathComponent("CodexCache")
        try FileManager.default.createDirectory(at: url,
                                                withIntermediateDirectories: true)
        return url
    }
    
    private func makeURL(for path: String) throws -> URL {
        let url = rootURL.appendingPathComponent(path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        return url
    }
    
    private func write(data: Data, to url: URL) throws {
        try data.write(to: url,
                       options: [.atomic, .completeFileProtection])
    }
}

