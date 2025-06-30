//
//  WH40KBuildsApp.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

@main
struct WH40KBuildsApp: App {
    
    // Dependencias como constantes normales
    private let authService: AuthService
    private let repo: BuildRepository
    private let sharedModelContainer: ModelContainer
    private let session: SessionStore
    
    // MARK: – Init
    init() {
        FirebaseApp.configure()

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        } else {
            print("❌ ERROR: Firebase clientID not found.")
        }
        
        self.authService = FirebaseAuthService()
        self.repo        = FirestoreBuildRepository()
        self.session     = SessionStore(service: FirebaseAuthService())
        
        let schema = Schema([ Item.self ])
        let config = ModelConfiguration(schema: schema,
                                        isStoredInMemoryOnly: false)
        self.sharedModelContainer = try! ModelContainer(for: schema,
                                                        configurations: [config])
    }
    
    // MARK: – UI
    var body: some Scene {
        WindowGroup {
            RootView(repo: repo, authService: authService)
                .environmentObject(session)
        }
        .modelContainer(sharedModelContainer)
    }
}
