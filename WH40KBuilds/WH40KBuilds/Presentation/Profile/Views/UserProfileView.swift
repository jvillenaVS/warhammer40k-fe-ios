//
//  UserProfileView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

import SwiftUI
import PhotosUI

struct UserProfileView: View {

    // ── Dependencias
    @EnvironmentObject private var session: SessionStore
    @StateObject private var vm: UserProfileViewModel

    // MARK: – Estilo
    private let bannerHeight: CGFloat = 200
    private let avatarSize:  CGFloat  = 100
    private let borderWidth: CGFloat  = 3

    // MARK: – UI State
    @State private var selectedItem: PhotosPickerItem?
    @State private var animateBorder = false
    @State private var isLoggingOut  = false

    // Dummy data (todavía sin back‑end)
    @State private var firstName = "John"
    @State private var lastName  = "Doe"
    @State private var bio       = "Chaotic good Wargamer 🛠️"
    @State private var username  = "wh40kuser"
    @State private var email     = "user@wh40k.com"
    @State private var totalBuilds = "10"
    @State private var lastUpdate  = "07/08/2025 – 02:00 PM"

    // MARK: – Init
    init(session: SessionStore,
         repo: AvatarRepository = FirebaseAvatarRepository()) {
        let uid = session.uid ?? ""
        _vm = StateObject(wrappedValue:
                            UserProfileViewModel(repo: repo, uid: uid))
    }

    // MARK: – Body
    var body: some View {
        VStack(spacing: 0) {
            banner
            usernameTag
            profileSections
        }
        .background(Color.appBackground)
        .onAppear {
            animateBorder = true
            Task { await vm.reloadAvatar() }      // carga caché + remoto más reciente
        }
        .onChange(of: selectedItem) { _, item in  // picker
            loadPickedImage(item)
        }
        .overlay(logoutOverlay)
    }

    // ───────── Sub‑vistas ─────────
    private var banner: some View {
        ZStack(alignment: .bottom) {
            Image("profile_banner")
                .resizable()
                .scaledToFill()
                .frame(height: bannerHeight)
                .clipped()
                .ignoresSafeArea(edges: .top)

            PhotosPicker(selection: $selectedItem, matching: .images) {
                avatarView
            }
            .offset(y: -(avatarSize + borderWidth) / 2)
        }
    }

    private var usernameTag: some View {
        Text("@\(username)")
            .font(.subheadline)
            .foregroundColor(.gray)
            .padding(.top, 8)
            .offset(y: -(avatarSize + borderWidth) / 2)
    }

    private var profileSections: some View {
        ScrollView {
            PersonalInfoSection(firstName: $firstName,
                                lastName:  $lastName,
                                bio:       $bio) { }

            Spacer().frame(height: 20)

            AccountInfoSection(username: $username,
                               email:    $email) { }

            Spacer().frame(height: 20)

            ActivityInfoSection(totalBuilds: $totalBuilds,
                                lastUpdate:  $lastUpdate) { }

            Spacer().frame(height: 20)

            SecurityActionsSection(
                onChangePassword: { /* pendiente */ },
                onLogout:        logout)
        }
        .padding(.top, -30)
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.buildTint,
                                                    .buildBackground.opacity(0.65)]),
                        center: .center),
                    lineWidth: borderWidth)
                .frame(width: avatarSize + borderWidth,
                       height: avatarSize + borderWidth)
                .rotationEffect(.degrees(animateBorder ? 360 : 0))
                .animation(.linear(duration: 6)
                             .repeatForever(autoreverses: false),
                           value: animateBorder)

            Group {
                if let img = vm.avatarUIImage {
                    Image(uiImage: img).resizable().scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                }
            }
            .frame(width: avatarSize, height: avatarSize)
            .clipShape(Circle())
        }
    }

    // ───────── Overlay de logout ─────────
    @ViewBuilder
    private var logoutOverlay: some View {
        if isLoggingOut {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .overlay(
                    ProgressView("Logging out…")
                        .padding(24)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 16))
                )
        }
    }

    // ───────── Helpers ─────────
    private func loadPickedImage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data  = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {

                vm.upload(image: image)    
            }
        }
    }

    private func logout() {
        isLoggingOut = true
        session.logout()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoggingOut = false
        }
    }
}

#Preview {
    let session = SessionStore(service: MockAuthService())
    NavigationStack {
        UserProfileView(session: session)
            .environmentObject(session)
    }
    .preferredColorScheme(.dark)
}

