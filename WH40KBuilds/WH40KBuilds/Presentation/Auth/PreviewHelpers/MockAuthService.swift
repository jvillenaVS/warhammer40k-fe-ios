//
//  MockAuthService.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Combine
import UIKit
import FirebaseAuth

final class MockAuthService: AuthService {
    
    // MARK: - Stream principal usado por SessionStore
    func authStateStream() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            continuation.yield(stateSubject.value)
            let cancellable = stateSubject
                .sink { continuation.yield($0) }
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
        let user = makePlaceholderUser(uid: "mock-\(UUID().uuidString)")
        stateSubject.send(.signedIn(user))
    }
    
    func signOut() async throws {
        try await Task.sleep(for: .milliseconds(100))
        stateSubject.send(.signedOut)
    }
    
    // MARK: - Combine extras (opcional para compatibilidad)
    private let stateSubject = CurrentValueSubject<AuthState, Never>(.signedOut)
    
    var authStatePublisher: AnyPublisher<String?, Never> {
        stateSubject
            .map {
                if case let .signedIn(user) = $0 { return user.uid }
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    var currentUserId: String? {
        if case let .signedIn(user) = stateSubject.value {
            return user.uid
        }
        return nil
    }
    
    func register(email: String, password: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func signInWithGoogle(presenting vc: UIViewController) -> AnyPublisher<Void, any Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// MARK: - Usuario ficticio (solo para DEBUG / previews)

#if DEBUG

private final class Placeholder: NSObject {
    let uid: String
    init(uid: String) { self.uid = uid }
}

/// Transforma el Placeholder en un User de Firebase (solo para pruebas visuales)
private func makePlaceholderUser(uid: String) -> User {
    unsafeBitCast(Placeholder(uid: uid), to: User.self)
}

#endif
