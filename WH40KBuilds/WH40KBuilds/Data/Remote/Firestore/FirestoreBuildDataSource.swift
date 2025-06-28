//
//  FirestoreBuildDataSource.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine
import FirebaseFirestore

final class FirestoreBuildDataSource {
    
    private let db = Firestore.firestore()
    private let collection = "builds"
    
    // MARK: - Create
    func create(_ build: Build) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self else { return }
            do {
                _ = try db.collection(collection).addDocument(from: build) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Read all (live listener)
    func readAll() -> AnyPublisher<[Build], Error> {
        let subject = PassthroughSubject<[Build], Error>()
        
        db.collection(collection)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                } else {
                    let builds = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Build.self)
                    } ?? []
                    subject.send(builds)
                }
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: - Update (merge true)
    func update(_ build: Build) -> AnyPublisher<Void, Error> {
        guard let id = build.id else {
            return Fail(error: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing document ID"]))
                .eraseToAnyPublisher()
        }
        
        return Future { [weak self] promise in
            do {
                try self?.db.collection(self?.collection ?? "")
                    .document(id)
                    .setData(from: build, merge: true) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Delete
    func delete(id: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.db.collection(self?.collection ?? "")
                .document(id)
                .delete { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}

