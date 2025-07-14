//
//  BuildListViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class BuildListViewModel: ObservableObject {
    
    @Published var builds: [Build] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    private let repository: BuildRepository
    private(set) var session: SessionStore?
    
    private var cancellables = Set<AnyCancellable>()
    private var firestoreCancellable: AnyCancellable?
    
    init(repository: BuildRepository) {
        self.repository = repository
    }
    
    private func bindSession() {
        session?.$authState
            .map { state -> String? in        
                if case let .signedIn(user) = state { return user.uid }
                return nil
            }
            .removeDuplicates()
            .sink { [weak self] uid in
                guard let self else { return }
                
                firestoreCancellable?.cancel()
                builds = []
                
                if let uid {
                    subscribeToBuilds(for: uid)
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToBuilds(for uid: String) {
        isLoading = true
        
        firestoreCancellable = repository.fetchBuilds(for: uid)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Sólo manejamos errores aquí
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] builds in
                self?.isLoading = false
                self?.builds = builds
            }
    }
            
    func delete(_ build: Build) {
        guard let id = build.id,
              let idx = builds.firstIndex(where: { $0.id == id }) else { return }
        
        IndexSet(integer: idx).forEach { index in
            guard let id = builds[index].id else { return }
            repository.deleteBuild(id: id)
                .sink(receiveCompletion: { _ in }, receiveValue: { })
                .store(in: &cancellables)
        }
    }
    
    func attachSession(_ session: SessionStore) {
        self.session = session
        bindSession()
    }
    
    func binding(for build: Build) -> Binding<Build>? {
        guard let idx = builds.firstIndex(where: { $0.id == build.id }) else {
            return nil
        }
        return Binding(
            get: { self.builds[idx] },
            set: { self.builds[idx] = $0 }
        )
    }
}
