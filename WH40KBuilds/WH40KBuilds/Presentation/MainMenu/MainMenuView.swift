//
//  MainMenuView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 1/7/25.
//

import SwiftUI
import _AVKit_SwiftUI

struct MainMenuView: View {
  
    @EnvironmentObject private var session: SessionStore
    
    @State private var showSyncMessage = false
    @State private var syncMessage = ""
    @State private var isSyncing = false
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""
    
    let repository: BuildRepository
    let authService: any AuthService
    private let player = AVPlayer(url: Bundle.main.url(forResource: "splash", withExtension: "mp4")!)
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    private let menuItems: [(title: String, icon: String)] = [
        ("My Builds",       "folder"),
        ("Explore Armies",  "magnifyingglass"),
        ("Rules",           "book"),
        ("Simulator",       "gamecontroller"),
        ("Profile",         "person.crop.circle"),
        ("Settings",        "gearshape.fill")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black.opacity(0.75))
                        .frame(height: 80)
                        .edgesIgnoringSafeArea(.top)
                    
                    CubeAnimationView(
                        showSide: $showSyncMessage,
                        front: BannerVideoView(player: player),
                        side:  ZStack {
                            Color.appBg.opacity(0.85)
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
                    .cubeStyle()
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            Text("WH40K Builder")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .padding(.top, 15)
                            
                            LazyVGrid(columns: gridColumns, spacing: 10) {
                                ForEach(menuItems.indices, id: \ .self) { idx in
                                    let item = menuItems[idx]
                                    MenuCardView(title: item.title,
                                                   icon: item.icon,
                                                   destination: destinationView(for: idx))
                                }
                            }
                            .padding(.horizontal)
                            
                            syncButton
                                .padding(.top, 12)
                        }
                        .padding(.vertical, 60)
                    }
                }
            }
        }
        .tint(.white)
    }
}

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
                let downloaded = try await CodexSyncManager.shared
                    .syncAllCodexData()
                
                let date = formattedDate()
                syncMessage = """
                    ✅ Sync done!
                    \(date)
                    Editions: \(downloaded.joined(separator: ", "))
                    """
                showSyncMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showSyncMessage = false
                }
            } catch {
                let date = formattedDate()
                syncMessage = """
                    ❌ Sync failed!
                    \(date)
                    """
                showSyncMessage = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    showSyncMessage = false
                }
            }
            isSyncing = false
        }
    }
    
    @ViewBuilder
    func destinationView(for index: Int) -> some View {
        switch index {
        case 0: BuildListView(repository: repository)
        case 1: ExploreArmiesView()
        case 2: RulesView()
        case 3: SimulatorView()
        case 4: UserProfileView(session: session)
        case 5: SettingsView()
        default: EmptyView()
        }
    }
    
    private func formattedDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy – hh:mm a"
        return df.string(from: Date())
    }
}
