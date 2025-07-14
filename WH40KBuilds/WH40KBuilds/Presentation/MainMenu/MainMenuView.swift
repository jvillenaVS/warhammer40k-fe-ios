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

                ScrollView {
                    VStack(spacing: 15) {
                        Text("WH40K Builder")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top, 15)

                        LazyVGrid(columns: gridColumns, spacing: 10) {
                            ForEach(menuItems.indices, id: \.self) { idx in
                                let item = menuItems[idx]
                                MenuCardView(title: item.title,
                                             icon: item.icon,
                                             destination: destinationView(for: idx))
                            }
                        }
                        .padding(.horizontal)

                        SyncButton(
                            showSyncMessage: $showSyncMessage,
                            syncMessage: $syncMessage,
                            isSyncing: $isSyncing
                        )
                        .padding(.top, 12)
                    }
                    .padding(.top, 225)
                    .padding(.bottom, 60)
                }

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black.opacity(0.75))
                        .frame(height: 80)
                        .edgesIgnoringSafeArea(.top)

                    CubeAnimation(
                        showSide: $showSyncMessage,
                        front: BannerVideo(player: player),
                        side: ZStack {
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
                    .frame(height: 170)
                    Spacer()
                }
            }
        }
        .tint(.white)
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
}
