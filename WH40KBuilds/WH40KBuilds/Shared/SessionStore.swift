//
//  SessionStore.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging

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
    
    func refreshFCMTokenIfNeeded() {
        guard case let .signedIn(user) = authState else { return }
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Error al obtener token FCM (foreground): \(error.localizedDescription)")
                return
            }
            guard let token = token else {
                print("❌ Token FCM es nulo (foreground)")
                return
            }
            
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            userRef.setData(["fcmToken": token], merge: true) { error in
                if let error = error {
                    print("❌ Error al guardar token FCM en Firestore (foreground): \(error.localizedDescription)")
                } else {
                    print("✅ Token FCM actualizado tras volver al foreground")
                }
            }
        }
    }
    
    // MARK: - Private
    private func listenAuthChanges() async {
        for await state in service.authStateStream() {
            self.authState = state
        }
    }
}
