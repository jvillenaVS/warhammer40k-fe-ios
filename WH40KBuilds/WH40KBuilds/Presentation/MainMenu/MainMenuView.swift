//
//  MainMenuView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 1/7/25.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

struct MainMenuView: View {
  
    @EnvironmentObject private var session: SessionStore
    let repo: BuildRepository
    let authService: any AuthService
    
    @State private var showSyncMessage = false
    @State private var syncMessage = ""
    
    // Items del menú principal
    private let menuItems: [(title: String, icon: String)] = [
        ("My Builds",       "folder"),
        ("Explore Armies",  "magnifyingglass"),
        ("Rules",           "book"),
        ("Simulator",       "gamecontroller"),
        ("Profile",         "person.crop.circle"),
        ("Settings",        "gearshape.fill")
    ]
    
    // Video splash
    private let player = AVPlayer(url: Bundle.main.url(forResource: "splash", withExtension: "mp4")!)
    
    // Layout
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // Sincronización
    @State private var isSyncing = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // ── Tope negro de 100 pt ───────────────────────
                    Rectangle()
                        .fill(Color.black.opacity(0.75))
                        .frame(height: 80)
                        .edgesIgnoringSafeArea(.top)
                    
                    // ── Video splash ───────────────────────────────
                    CubeFlipView(
                        showSide: $showSyncMessage,
                        front: VideoPlayerView(player: player),
                        side:  ZStack {
                            Color.appBg
                            VStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.largeTitle)
                                Text(syncMessage)
                                    .multilineTextAlignment(.center)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                        }
                    )
                    .frame(height: 200)     
                    .cornerRadius(12)
                    .offset(y: -70)
                    .padding(.bottom, -130)
                    
                    // ── Contenido principal ────────────────────────
                    ScrollView {
                        VStack(spacing: 15) {
                            Text("WH40K Builder")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .padding(.top, 15)
                            
                            // 6 tarjetas
                            LazyVGrid(columns: gridColumns, spacing: 10) {
                                ForEach(menuItems.indices, id: \ .self) { idx in
                                    let item = menuItems[idx]
                                    NavigationCard(title: item.title,
                                                   icon: item.icon,
                                                   destination: destinationView(for: idx))
                                }
                            }
                            .padding(.horizontal)
                            
                            // Botón de sincronización
                            syncButton
                                .padding(.top, 12)
                        }
                        .padding(.vertical, 60)
                    }
                }
            }
        }
        .tint(.white)
        // Alert de error
        .alert("Sync Error",
               isPresented: $showErrorAlert,
               actions: { Button("OK", role: .cancel) {} },
               message: { Text(errorMessage) })
    }
}

// ── Sincronización -----------------------------------------------------------
private extension MainMenuView {
    
    var syncButton: some View {
        Button(action: onSyncTapped) {
            HStack(spacing: 8) {
                Image(systemName: isSyncing
                      ? "arrow.triangle.2.circlepath.circle.fill"
                      : "arrow.triangle.2.circlepath")
                    .imageScale(.large)
                    .rotationEffect(.degrees(isSyncing ? 360 : 0))
                    .animation(isSyncing
                               ? .easeInOut(duration: 1).repeatForever(autoreverses: false)
                               : .default, value: isSyncing)
                
                Text(isSyncing ? "Syncing…" : "Sync Codex Data")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 28)
        }
        .buttonStyle(NeumorphicStyle())
        .disabled(isSyncing)
    }
    
    func onSyncTapped() {
        isSyncing = true
        Task {
            do {
                let codexStore  = try! LocalCodexStore()
                let syncManager = CodexSyncManager(store: codexStore)
                try await syncManager.syncAllCodexData()
                
                isSyncing = false
                syncMessage = "✅ Sync done!\n\(formattedDate())"
                showSyncMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showSyncMessage = false
                }
            } catch {
                isSyncing = false
                syncMessage = "❌ Sync Failure!\n\(formattedDate())"
                showSyncMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showSyncMessage = false
                }
            }
        }
    }
    
    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy – hh:mm a"
        return df.string(from: Date())
    }
}

// ── Custom ButtonStyle (neumórfico 3‑D) -------------------------------------
struct NeumorphicStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.buildBackgroundColor)
                    .shadow(color: .black.opacity(configuration.isPressed ? 0 : 0.4),
                            radius: 6, x: 0, y: 4)
                    .shadow(color: .white.opacity(configuration.isPressed ? 0 : 0.08),
                            radius: 6, x: 0, y: -4)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// ── Destinos de navegación ---------------------------------------------------
private extension MainMenuView {
    @ViewBuilder
    func destinationView(for index: Int) -> some View {
        switch index {
        case 0: BuildListView(repository: repo, session: session)
        case 1: ExploreArmiesView()
        case 2: RulesReferencesView()
        case 3: SimulatorView()
        case 4: ProfileView()
        case 5: SettingsView()
        default: EmptyView()
        }
    }
}

// ── Tarjeta de menú ----------------------------------------------------------
struct NavigationCard<Destination: View>: View {
    let title: String
    let icon: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

// ── Video de cabecera --------------------------------------------------------
struct VideoPlayerView: View {
    let player: AVPlayer

    var body: some View {
        VideoPlayer(player: player)
            .frame(height: 220)
            .cornerRadius(12)
            .onAppear {
                player.play()
                player.isMuted = true
                player.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                       object: player.currentItem,
                                                       queue: .main) { _ in
                    player.seek(to: .zero)
                    player.play()
                }
            }
            .onDisappear { player.pause() }
            .allowsHitTesting(false)  
    }
}

// ── Placeholders -------------------------------------------------------------
struct ExploreArmiesView: View { var body: some View { Color.black.ignoresSafeArea().overlay(Text("Explore Armies").foregroundColor(.white)) } }
struct RulesReferencesView: View { var body: some View { Color.black.ignoresSafeArea().overlay(Text("Rules").foregroundColor(.white)) } }
struct SimulatorView: View { var body: some View { Color.black.ignoresSafeArea().overlay(Text("Simulator").foregroundColor(.white)) } }
struct ProfileView: View { var body: some View { Color.black.ignoresSafeArea().overlay(Text("Profile").foregroundColor(.white)) } }
struct SettingsView: View { var body: some View { Color.black.ignoresSafeArea().overlay(Text("Settings").foregroundColor(.white)) } }

