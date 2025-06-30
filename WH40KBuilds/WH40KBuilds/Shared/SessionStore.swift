//
//  SessionStore.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    
    // Publicado para que las vistas reaccionen
    @Published private(set) var authState: AuthState = .loading
    
    private let service: any AuthService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(service: any AuthService) {
        self.service = service
        Task { await listenAuthChanges() }   // Arranca el listener
    }
    
    // MARK: - Computed helpers
    func logout() {
        self.service.logout()
                .sink(receiveCompletion: { _ in }, receiveValue: { })
                .store(in: &cancellables)
        }
    
    var isLoggedIn: Bool {
        if case .signedIn = authState { return true }
        return false
    }
    
    var uid: String? {
        if case let .signedIn(user) = authState { return user.uid }
        return nil
    }
    
    // MARK: - Public actions
    
    func signOut() async throws {
        try await service.signOut()
    }
    
    // MARK: - Private
    private func listenAuthChanges() async {
        for await state in service.authStateStream() {
            self.authState = state
        }
    }
}
