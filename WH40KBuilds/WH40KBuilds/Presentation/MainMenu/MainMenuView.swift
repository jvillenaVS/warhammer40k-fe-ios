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
    
    /// Datos de menú: título + SF Symbol
    private let menuItems: [(title: String, icon: String)] = [
        ("My Builds", "folder"),
        ("Explore Armies", "magnifyingglass"),
        ("Rules", "book"),
        ("Simulator", "gamecontroller"),
        ("Profile", "person.crop.circle"),
        ("Settings", "gearshape.fill")
    ]
    
    private let player = AVPlayer(url: Bundle.main.url(forResource: "splash", withExtension: "mp4")!)
    
    // Grilla 2 × 3
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VideoPlayerView(player: player)
                        .frame(height: 160)
                        .ignoresSafeArea(.all)
                        .allowsHitTesting(false)   
                    
                    ScrollView {
                        VStack() {
                          
                            Text("WH40K Builder")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            LazyVGrid(columns: gridColumns, spacing: 24) {
                                ForEach(menuItems.indices, id: \.self) { index in
                                    let item = menuItems[index]
                                    NavigationCard(title: item.title,
                                                   icon: item.icon,
                                                   destination: destinationView(for: index))
                                }
                            }
                            .padding(.horizontal)
                        }
                
                    }
                
                }
            }
        }
        .tint(.white)
    }
    
    /// Devuelve la vista de destino según el índice del menú.
    @ViewBuilder
    private func destinationView(for index: Int) -> some View {
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

// MARK: - NavigationCard
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
            .onDisappear {
                player.pause()
            }
    }
}

// MARK: - Placeholder Views

struct ExploreArmiesView: View {
    var body: some View {
        Text("Explore Armies")
            .foregroundColor(.white)
            .background(Color.black.ignoresSafeArea())
    }
}

struct RulesReferencesView: View {
    var body: some View {
        Text("Rules")
            .foregroundColor(.white)
            .background(Color.black.ignoresSafeArea())
    }
}

struct SimulatorView: View {
    var body: some View {
        Text("Simulator")
            .foregroundColor(.white)
            .background(Color.black.ignoresSafeArea())
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .foregroundColor(.white)
            .background(Color.black.ignoresSafeArea())
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .foregroundColor(.white)
            .background(Color.black.ignoresSafeArea())
    }
}

