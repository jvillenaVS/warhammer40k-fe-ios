//
//  RootView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 29/6/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    let repo: BuildRepository
    let authService: any AuthService
    
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            switch session.authState {
            case .signedIn:
                MainMenuView(repo: repo, authService: authService)
            case .signedOut:
                LoginView(authService: authService)
            case .loading:
                Color.black
                    .ignoresSafeArea()
            }
            
            if showSplash {
                ProgressView()
                    .transition(.opacity)
            }
        }
        .onChange(of: session.authState) { _, state in
            if state != .loading {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSplash = false
                }
            }
        }
    }
}


