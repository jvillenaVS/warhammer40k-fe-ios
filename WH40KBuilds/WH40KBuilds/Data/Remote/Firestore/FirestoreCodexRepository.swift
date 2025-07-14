//
//  FirestoreCodexRepository.swift
//  WH40KBuilds
//

import Combine
import FirebaseFirestore

final class FirestoreCodexRepository: CodexRepository {
    
    private let db = Firestore.firestore()
    
    // ---------------------------------------------------------------------
    // Error stream: si una consulta falla, publicamos el error aquí
    // ---------------------------------------------------------------------
    private let errorSubject = CurrentValueSubject<Error?, Never>(nil)
    var errorPublisher: AnyPublisher<Error?, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // ---------------------------------------------------------------------
    // MARK: – API CodexRepository
    // ---------------------------------------------------------------------
    func editions() -> AnyPublisher<[EditionCodex], Error> {
        let subject = PassthroughSubject<[EditionCodex], Error>()

        db.collection("editions")
          .addSnapshotListener { [weak self] snapshot, error in
              if let error {
                  subject.send(completion: .failure(error))
                  self?.errorSubject.send(error)
                  return
              }

              let editions = snapshot?.documents.map { doc in
                  EditionCodex(id: doc.documentID)
              } ?? []

              subject.send(editions)
              if editions.isEmpty {
                  self?.errorSubject.send(nil)
              }
          }

        return subject.eraseToAnyPublisher()
    }
    
    func factions(edition: String) -> AnyPublisher<[FactionCodex], Error> {
        let path = "editions/\(edition)/factions"
        let subject = PassthroughSubject<[FactionCodex], Error>()
        
        db.collection(path)
          .addSnapshotListener { [weak self] snapshot, error in
              if let error {
                  subject.send(completion: .failure(error))
                  self?.errorSubject.send(error)
                  return
              }
              
              let docs = snapshot?.documents.compactMap { doc -> FactionCodex? in
                  var faction = try? doc.data(as: FactionCodex.self)
                  faction?.editionId = edition // ← inyectamos edición aquí
                  return faction
              } ?? []
              
              subject.send(docs)
              if docs.isEmpty { self?.errorSubject.send(nil) }
          }
        
        return subject.eraseToAnyPublisher()
    }
    
    func subFactions(edition: String,
                     faction: String) -> AnyPublisher<[SubFactionCodex], Error> {
        collection(path: "editions/\(edition)/factions/\(faction)/subfactions")
    }
    
    func detachments(edition: String,
                     faction: String) -> AnyPublisher<[DetachmentCodex], Error> {
        collection(path: "editions/\(edition)/factions/\(faction)/detachments")
    }
    
    func units(edition: String,
               faction: String) -> AnyPublisher<[UnitCodex], Error> {
        collection(path: "editions/\(edition)/factions/\(faction)/units")
    }
    
    // ---------------------------------------------------------------------
    // MARK: – Private helper (type‑erased publisher + error forwarding)
    // ---------------------------------------------------------------------
    private func collection<T: Decodable>(path: String) -> AnyPublisher<[T], Error> {
        let subject = PassthroughSubject<[T], Error>()
        
        db.collection(path)
          .addSnapshotListener { [weak self] snapshot, error in
              
              if let error {
                  subject.send(completion: .failure(error))
                  self?.errorSubject.send(error)
                  return
              }
              
              let docs = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
              subject.send(docs)
              
              if docs.isEmpty { self?.errorSubject.send(nil) }
          }
        return subject.eraseToAnyPublisher()
    }
}
