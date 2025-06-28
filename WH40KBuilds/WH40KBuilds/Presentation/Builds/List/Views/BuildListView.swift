//
//  BuildListView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildListView: View {
    
    @StateObject private var vm: BuildListViewModel
    
    // Inyección sencilla para previews / tests
    init(repository: BuildRepository = FirestoreBuildRepository()) {
        _vm = StateObject(wrappedValue: BuildListViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Loading Builds…")
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                } else if vm.builds.isEmpty {
                    ContentUnavailableView(
                        "No builds yet",
                        systemImage: "tray",
                        description: Text("Tap the ➕ button to add a sample build")
                    )
                } else {
                    List {
                        ForEach(vm.builds) { build in
                            NavigationLink {
                                BuildDetailView(
                                    viewModel: BuildDetailViewModel(
                                        build: build,
                                        repo: FirestoreBuildRepository()
                                    )
                                )
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(build.name).font(.headline)
                                    Text(build.faction.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete(perform: vm.delete) // Swipe‑to‑delete
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("WH40K Builds")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        BuildFormView(
                            vm: BuildFormViewModel(
                                repository: FirestoreBuildRepository()
                            )
                        )
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    BuildListView(repository: MockBuildRepository()) // crea un mock para previews
}

