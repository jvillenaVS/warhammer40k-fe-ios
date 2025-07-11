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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var environment = AppEnvironment()
    private let sharedModelContainer: ModelContainer
    
    // MARK: – Init
    init() {
        let schema = Schema([ Item.self ])
        let config = ModelConfiguration(schema: schema,
                                        isStoredInMemoryOnly: false)
        self.sharedModelContainer = try! ModelContainer(for: schema,
                                                        configurations: [config])
    }
    
    // MARK: – UI
    var body: some Scene {
        WindowGroup {
            RootView(repository: environment.repository, authService: environment.authService)
                .environmentObject(environment.session)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                environment.session.refreshFCMTokenIfNeeded()
            }
        }
    }
}

