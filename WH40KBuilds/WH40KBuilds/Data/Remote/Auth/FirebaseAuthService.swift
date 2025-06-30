//
//  FirebaseAuthService.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

// MARK: - AuthService implementation with Firebase
final class FirebaseAuthService: AuthService {
    
    func authStateStream() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            let handle = Auth.auth().addStateDidChangeListener { _, user in
                if let user {
                    continuation.yield(.signedIn(user))
                } else {
                    continuation.yield(.signedOut)
                }
            }
            continuation.onTermination = { _ in
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    }
    
    // ② Sign‑in
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    // ③ Sign‑out
    func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - Auth state publisher ------------------------------------------
    private let authStateSubject = CurrentValueSubject<String?, Never>( Auth.auth().currentUser?.uid )
    private var handle: AuthStateDidChangeListenerHandle?
    
    // Expuesto al exterior
    var authStatePublisher: AnyPublisher<String?, Never> {
        authStateSubject.eraseToAnyPublisher()
    }
    
    // Instala listener sólo una vez
    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.authStateSubject.send(user?.uid)
        }
    }
    
    deinit {
        if let handle { Auth.auth().removeStateDidChangeListener(handle) }
    }
    
    // MARK: Current user -----------------------------------------------------
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // MARK: Email / Password -------------------------------------------------
    func register(email: String, password: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { _, error in
                error == nil ? promise(.success(())) : promise(.failure(error!))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                error == nil ? promise(.success(())) : promise(.failure(error!))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                error == nil ? promise(.success(())) : promise(.failure(error!))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: Sign‑in with Google ---------------------------------------------
    func signInWithGoogle(presenting vc: UIViewController) -> AnyPublisher<Void, Error> {
        Future { promise in
            // 1. Retrieve Client‑ID from Firebase config
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                promise(.failure(NSError(domain: "google",
                                         code: -1,
                                         userInfo: [NSLocalizedDescriptionKey: "Missing Client ID"])))
                return
            }
            // 2. Configure the shared instance
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            
            // 3. Launch Google flow
            GIDSignIn.sharedInstance.signIn(withPresenting: vc) { signInResult, error in
                if let error = error {
                    promise(.failure(error)); return
                }
                
                guard
                    let user      = signInResult?.user,
                    let idToken   = user.idToken?.tokenString
                else {
                    promise(.failure(NSError(domain: "google",
                                             code: -2,
                                             userInfo: [NSLocalizedDescriptionKey: "Invalid Google token"])))
                    return
                }
                
                let accessToken = user.accessToken.tokenString       
                
                // 4. Create Firebase credential
                let credential = GoogleAuthProvider.credential(
                    withIDToken: idToken,
                    accessToken: accessToken
                )
                
                // 5. Sign in to Firebase
                Auth.auth().signIn(with: credential) { _, error in
                    error == nil ? promise(.success(())) : promise(.failure(error!))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

