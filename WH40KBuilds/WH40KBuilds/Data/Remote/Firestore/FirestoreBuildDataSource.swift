//
//  FirestoreBuildDataSource.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine
import FirebaseFirestore

/// Encapsula la comunicación directa con Cloud Firestore.
final class FirestoreBuildDataSource {
    
    private let db = Firestore.firestore()
    private let collection = "builds"
    
    // MARK: - Fetch (listener en vivo)
    func listenToBuilds(for uid: String) -> AnyPublisher<[Build], Error> {
        let subject = PassthroughSubject<[Build], Error>()
        
        db.collection(collection)
            .whereField("createdBy", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error { subject.send(completion: .failure(error)) }
                else if let docs = snapshot?.documents {
                    let builds = docs.compactMap { try? $0.data(as: Build.self) }
                    subject.send(builds)
                }
            }
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Add
    func create(_ build: Build) -> AnyPublisher<Void, Error> {
        Future { promise in
            do {
                _ = try self.db.collection(self.collection)
                    .addDocument(from: build) { error in
                        error == nil ? promise(.success(()))
                                     : promise(.failure(error!))
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Update
    func update(_ build: Build) -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let id = build.id else {
                promise(.failure(NSError(domain: "build",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Missing build ID"])))
                return
            }
            do {
                try self.db.collection(self.collection)
                    .document(id)
                    .setData(from: build, merge: true) { error in
                        error == nil ? promise(.success(()))
                                     : promise(.failure(error!))
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Delete
    func delete(id: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            self.db.collection(self.collection)
                .document(id)
                .delete { error in
                    error == nil ? promise(.success(()))
                                 : promise(.failure(error!))
                }
        }
        .eraseToAnyPublisher()
    }
}


