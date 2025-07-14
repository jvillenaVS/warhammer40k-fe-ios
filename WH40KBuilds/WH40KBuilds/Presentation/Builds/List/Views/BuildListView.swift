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

    @State private var selected: Build?
    @State private var showForm = false
    @State private var showDelete = false
    @State private var buildToDelete: Build?
    @State private var snapshotImage: UIImage? = nil
    @State private var hideNavBar = false

    init(repository: BuildRepository = FirestoreBuildRepository()) {
        self.repository = repository
        _vm = StateObject(wrappedValue: BuildListViewModel(repository: repository))
    }

    var body: some View {
        ZStack {
            Color.appBg.ignoresSafeArea()

            listContent
                .padding(.horizontal)
                .navigationTitle(hideNavBar ? "" : "Builds")
                .navigationBarHidden(hideNavBar)
        }
        .navigationBarStyle()
        .overlay(alignment: .bottomTrailing) {
            FAButton(showForm: $showForm)
        }
        .overlay {
            if showDelete, let doomed = buildToDelete, let snapshot = snapshotImage {
                DeleteSnapshotView(
                    snapshot: snapshot,
                    onDelete: {
                        vm.delete(doomed)
                        withAnimation {
                            showDelete = false
                            hideNavBar = false
                        }
                    }, onCancel: {
                        withAnimation {
                            showDelete = false
                            hideNavBar = false
                        }
                    }
                )
                .zIndex(1)
            }
        }
        .onAppear {
            if vm.session == nil { vm.attachSession(session) }
        }
        .navigationDestination(item: $selected) { build in
            if let binding = vm.binding(for: build) {
                BuildDetailView(build: binding, repository: repository)
            }
        }
        .navigationDestination(isPresented: $showForm) {
            BuildFormView(repository: repository, codex: FirestoreCodexRepository())
        }
        .tint(.white)
    }
    
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
            BuildListSectionView(
                builds: vm.builds,
                onView: { selected = $0 },
                onTrash: { takeSnapshotAndShowDelete(for: $0) }
            )
        }
    }

    private func takeSnapshotAndShowDelete(for build: Build) {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first?.windows.first {
            snapshotImage = window.rootViewController?.view.snapshot()
        }
        buildToDelete = build
        withAnimation {
            showDelete = true
            hideNavBar = true
        }
    }
    
}
