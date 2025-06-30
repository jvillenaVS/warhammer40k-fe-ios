//
//  AuthService.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation
import Combine
import UIKit

protocol AuthService {
    
    /// Flujo con los cambios de sesión
    func authStateStream() -> AsyncStream<AuthState>
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    
    // User
    var currentUserId: String? { get }
    
    // Email / password
    func register(email: String, password: String) -> AnyPublisher<Void, Error>
    func login(email: String, password: String) -> AnyPublisher<Void, Error>
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func logout() -> AnyPublisher<Void, Error>
    
    // Google
    func signInWithGoogle(presenting vc: UIViewController) -> AnyPublisher<Void, Error>
    
    /// Publisher que emite el UID (o nil) cada vez que cambia la sesión
    var authStatePublisher: AnyPublisher<String?, Never> { get }
    
}
