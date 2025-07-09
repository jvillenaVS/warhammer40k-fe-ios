//
//  BuildListViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

@MainActor
final class BuildListViewModel: ObservableObject {
    
    // MARK: - Published state
    @Published var builds: [Build] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Deps
    private let repository: BuildRepository
    private(set) var session: SessionStore?
    
    private var cancellables = Set<AnyCancellable>()
    private var firestoreCancellable: AnyCancellable?
    
    // MARK: - Init
    init(repository: BuildRepository) {
        self.repository = repository
    }
    
    // Escucha el cambio de uid
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
    
    // Listener Firestore → publisher Combine
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
        
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
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
}
