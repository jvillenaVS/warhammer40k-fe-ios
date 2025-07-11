//
//  AppEnvironment.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 10/7/25.
//

import Foundation
import Combine

@MainActor
final class AppEnvironment: ObservableObject {
    let authService: AuthService
    let repository: BuildRepository
    let session: SessionStore
    
    init() {
        self.authService = FirebaseAuthService()
        self.repository = FirestoreBuildRepository()
        self.session = SessionStore(service: authService)
    }
}
