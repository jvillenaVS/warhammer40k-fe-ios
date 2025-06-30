//
//  BuildListView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildListView: View {
    
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm: BuildListViewModel
    private let repository: BuildRepository
    
    @State private var showForm = false
    
    init(repository: BuildRepository = FirestoreBuildRepository(),
         session: SessionStore) {
        self.repository = repository
        _vm = StateObject(wrappedValue: BuildListViewModel(
            repository: repository,
            session: session
        ))
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("WH40K Builds")
                .toolbar {
                    logoutButton
                    addButton
                }
                .navigationDestination(isPresented: $showForm) {
                    BuildFormView(
                        repository: repository,
                        session: session
                    )
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            ProgressView("Loading Builds…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = vm.errorMessage {
            VStack {
                Text("Error loading builds:")
                    .font(.headline)
                Text(error)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else if vm.builds.isEmpty {
            ContentUnavailableView(
                session.isLoggedIn ? "No builds yet" : "Login required",
                systemImage: "tray",
                description: Text(
                    session.isLoggedIn
                    ? "Tap + to create your first build."
                    : "Please log in to see or create builds.")
            )
        } else {
            List {
                ForEach($vm.builds) { $build in
                    NavigationLink {
                        BuildDetailView(
                            build: $build,
                            repository: repository
                        )
                    } label: {
                        VStack(alignment: .leading) {
                            Text(build.name)
                                .font(.headline)
                            Text(build.faction.name)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: vm.delete)
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: – Botón "+"
    @ToolbarContentBuilder
    private var addButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                showForm = true
            } label: {
                Image(systemName: "plus")
            }
            .disabled(!session.isLoggedIn)
        }
    }
    
    // MARK: – Botón Logout (muñequito)
    @ToolbarContentBuilder
    private var logoutButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                session.logout()
            } label: {
                Image(systemName: "person.crop.circle.badge.xmark")
            }
            .help("Logout")
        }
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
}
