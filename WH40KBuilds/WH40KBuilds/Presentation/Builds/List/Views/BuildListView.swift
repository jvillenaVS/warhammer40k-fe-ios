//
//  BuildListView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

// MARK: – BuildListView
struct BuildListView: View {
    
    // ── Dependencias ────────────────────────────────────────────────
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm: BuildListViewModel
    private let repository: BuildRepository
    
    // Navegación
    @State private var selected: Build?
    @State private var showForm = false
    
    // Delete flags
    @State private var showDelete = false
    @State private var buildToDelete: Build?
    
    // Init con DI
    init(repository: BuildRepository = FirestoreBuildRepository(),
         session: SessionStore) {
        self.repository = repository
        _vm = StateObject(wrappedValue: BuildListViewModel(
            repository: repository,
            session: session
        ))
    }
    
    // ── Body ───────────────────────────────────────────────────────
    var body: some View {
       
        ZStack(alignment: .center) {
            Color.appBg.ignoresSafeArea()
            
            listContent
                .padding(.horizontal)
                .navigationTitle("Builds")
                .scrollIndicators(.hidden)
            
        }
        .navigationBarStyle()
        .overlay(alignment: .bottomTrailing) {
            addFAB
            
            if showDelete, let doomed = buildToDelete {
                DeleteView(
                    onDelete: {
                        delete(doomed)
                        showDelete = false
                    },
                    onCancel: { showDelete = false }
                )
                .zIndex(1)
            }
        }
 
        .navigationDestination(item: $selected) { build in
            BuildDetailView(
                build: binding(for: build),
                repository: repository
            )
        }
        .tint(.white)

        .navigationDestination(isPresented: $showForm) {
            BuildFormView(repository: repository,
                          codex: FirestoreCodexRepository(),
                          session: session)
        }
        .background(Color(.systemGray6).opacity(0.05))
        .tint(.white)
        
        
       
    }
       
}

// MARK: – Contenido principal
private extension BuildListView {
    
    @ViewBuilder
    var listContent: some View {
        if vm.isLoading {
            ProgressView("Loading Builds…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.errorMessage {
            ErrorStateView(error: error)
        } else if vm.builds.isEmpty {
            EmptyStateView(isLoggedIn: session.isLoggedIn)
        } else {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    HeaderView(
                        title: "List of Builds",
                        subtitle: "Quick access to your custom armies."
                    )
                    .padding(.vertical, 20)
                    .padding(.horizontal, 8)
                    
                    ForEach(vm.builds) { build in
                        BuildRowView(
                            build: build,
                            onView: { selected = build },
                            onTrash: {
                                buildToDelete = build
                                showDelete = true
                            }
                        )
                    }
                }
            }
        }
    }
    
    // Botón flotante +
    var addFAB: some View {
        Button { showForm = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.buildBackgroundColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing)
        .padding(.bottom, 14)
        .disabled(!session.isLoggedIn)
    }
    
    // Borra build
    func delete(_ build: Build) {
        guard let id = build.id,
              let idx = vm.builds.firstIndex(where: { $0.id == id }) else { return }
        vm.delete(at: IndexSet(integer: idx))
    }
    
    // Binding para detalle
    func binding(for build: Build) -> Binding<Build> {
        guard let idx = vm.builds.firstIndex(where: { $0.id == build.id }) else {
            fatalError("Build not found")
        }
        return $vm.builds[idx]
    }
}

// MARK: – Row ----------------------------------------------------------------
private struct BuildRowView: View {
    let build: Build
    let onView: () -> Void
    let onTrash: () -> Void
    
    // Tamaño imagen vertical
    private let imgSize = CGSize(width: 100, height: 120)
    
    var body: some View {
        HStack(spacing: 16) {
           
            let imgName = "faction_\(build.faction.name.lowercased())"
            let uiImage = UIImage(named: imgName) ?? UIImage(named: "wh-logo")!
            
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: imgSize.width, height: imgSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(build.name)
                        .font(.headline)
                        .foregroundColor(.buildTitleColor)
                        .lineLimit(2)
                    Text(build.faction.name)
                        .font(.subheadline)
                        .foregroundColor(.buildSubTitleColor)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    RectButton(title: "View",
                               bg: .buildBackgroundColor,
                               fg: .white,
                               action: onView)
                    RectButton(title: "Trash",
                               bg: .clear,
                               fg: .buildTintColor,
                               action: onTrash)
                }
            }
            .frame(height: imgSize.height)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Botón rectangular
private struct RectButton: View {
    let title: String
    let bg: Color
    let fg: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(width: 100, height: 38)
                .background(bg)
                .foregroundColor(fg)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: – Header
private struct HeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("wh-list-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 30, height: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.buildTitleColor)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.buildSubTitleColor)
            }
        }
    }
}

// MARK: – Empty & Error
private struct EmptyStateView: View {
    let isLoggedIn: Bool
    var body: some View {
        ContentUnavailableView(
            isLoggedIn ? "No builds yet" : "Login required",
            systemImage: "tray",
            description: Text(
                isLoggedIn
                ? "Tap + to create your first build."
                : "Please log in to see or create builds.")
        )
        .foregroundColor(.white)
    }
}

private struct ErrorStateView: View {
    let error: String
    var body: some View {
        VStack {
            Text("Error loading builds:")
                .font(.headline)
            Text(error)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.white)
        .padding()
    }
}

// MARK: – Preview
#Preview {
    let session = SessionStore(service: MockAuthService())
    BuildListView(
        repository: MockBuildRepository(),
        session: session
    )
    .environmentObject(session)
    .preferredColorScheme(.dark)
}
