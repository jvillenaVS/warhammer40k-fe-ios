//
//  Item.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

/*
Ahora te comparto el código de las clases de la carpeta de Presentation para que guardes la versión más reciente

Capa: Presentation
MockAuthService.swift
WH40KBuilds/Presentation/Auth/PreviewHelpers/MockAuthService

//
//  MockAuthService.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Combine
import UIKit
import FirebaseAuth

final class MockAuthService: AuthService {
    
    // MARK: - Stream principal usado por SessionStore
    func authStateStream() -> AsyncStream<AuthState> {
        AsyncStream { continuation in
            continuation.yield(stateSubject.value)
            let cancellable = stateSubject
                .sink { continuation.yield($0) }
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
        let user = makePlaceholderUser(uid: "mock-\(UUID().uuidString)")
        stateSubject.send(.signedIn(user))
    }
    
    func signOut() async throws {
        try await Task.sleep(for: .milliseconds(100))
        stateSubject.send(.signedOut)
    }
    
    // MARK: - Combine extras (opcional para compatibilidad)
    private let stateSubject = CurrentValueSubject<AuthState, Never>(.signedOut)
    
    var authStatePublisher: AnyPublisher<String?, Never> {
        stateSubject
            .map {
                if case let .signedIn(user) = $0 { return user.uid }
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    var currentUserId: String? {
        if case let .signedIn(user) = stateSubject.value {
            return user.uid
        }
        return nil
    }
    
    func register(email: String, password: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func signInWithGoogle(presenting vc: UIViewController) -> AnyPublisher<Void, any Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

// MARK: - Usuario ficticio (solo para DEBUG / previews)

#if DEBUG

private final class Placeholder: NSObject {
    let uid: String
    init(uid: String) { self.uid = uid }
}

/// Transforma el Placeholder en un User de Firebase (solo para pruebas visuales)
private func makePlaceholderUser(uid: String) -> User {
    unsafeBitCast(Placeholder(uid: uid), to: User.self)
}

#endif

AuthViewModel.swift
WH40KBuilds/Presentation/Auth/ViewModels/AuthViewModel

//
//  AuthViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation
import Combine
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Input
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - Output
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isAuthenticated = false
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(authService: AuthService) {
        self.authService = authService
        self.isAuthenticated = authService.currentUserId != nil
    }
    
    // MARK: - Intents
    func login() {
        guard validateEmailAndPassword() else { return }
        isLoading = true
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.isAuthenticated = true
            }
            .store(in: &cancellables)
    }
    
    func register() {
        guard validateEmailAndPassword() else { return }
        isLoading = true
        
        authService.register(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.isAuthenticated = true
            }
            .store(in: &cancellables)
    }
    
    func forgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Enter your e‑mail first"
            return
        }
        isLoading = true
        authService.resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.errorMessage = "A reset link was sent to your email."
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func logout() {
        _ = authService.logout()
    }
    
    func showError(_ message: String) {
        errorMessage = message
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func signInWithGoogle(presenting vc: UIViewController) {
        isLoading = true
        authService.signInWithGoogle(presenting: vc)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.showError(error.localizedDescription)
                } else {
                    self?.isAuthenticated = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    // MARK: - Helpers
    private func validateEmailAndPassword() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "E‑mail and password are required."
            return false
        }
        return true
    }
}

GoogleSignInButton.swift
WH40KBuilds/Presentation/Auth/Views/GoogleSignInButton

//
//  GoogleSignInButton.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
    let action: () -> Void
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func tapped() { action() }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UIView {
        // Contenedor para poder añadir el gesto si lo necesitas
        let container = UIView()
        
        let googleButton = GIDSignInButton()
        googleButton.style = .wide
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(googleButton)
        
        // Autolayout: que el botón llene el contenedor
        NSLayoutConstraint.activate([
            googleButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            googleButton.topAnchor.constraint(equalTo: container.topAnchor),
            googleButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // ✅ Gestor de toque: UITapGestureRecognizer
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.tapped)
        )
        container.addGestureRecognizer(tap)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Nada que actualizar
    }
}

LoginView.swift
WH40KBuilds/Presentation/Auth/Views/LoginView

//
//  LoginView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct LoginView: View {
    
    // MARK: - ViewModel
    @StateObject private var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Focus
    @FocusState private var focusedField: Field?
    enum Field { case email, password }
    
    // MARK: - Init
    init(authService: AuthService = FirebaseAuthService()) {
        _vm = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // --- Logo & title ------------------------------------------------
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkerboard")
                        .resizable()
                        .frame(width: 64, height: 64)
                    Text("WH40K Builds")
                        .font(.largeTitle).bold()
                }
                .padding(.bottom, 32)
                
                // --- Email & Password fields -----------------------------------
                Group {
                    TextField("E‑mail", text: $vm.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                    
                    SecureField("Password (min 6)", text: $vm.password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.continue)
                        .onSubmit { vm.login() }
                }
                
                // --- Login button ----------------------------------------------
                Button(action: vm.login) {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading)
                
                // --- Google Sign‑In -------------------------------------------
                GoogleSignInButton {
                    guard let rootVC =  UIApplication.topViewController() else {
                        print("❌ No root view controller found")
                        return
                    }
                    vm.signInWithGoogle(presenting: rootVC)
                }
                .frame(height: 48)
                .padding(.top, 4)
                
                // --- Secondary links ------------------------------------------
                HStack {
                    NavigationLink("Register") {
                        RegisterView(authService: FirebaseAuthService())
                    }
                    Spacer()
                    Button("Forgot password?") { vm.forgotPassword() }
                }
                .font(.footnote)
            }
            .padding()
            
            // --- Hide keyboard on tap outside ---------------------------------
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
            
            // --- Alert for errors & messages ----------------------------------
            .alert("Message",
                   isPresented: Binding(
                       get: { vm.errorMessage != nil },
                       set: { _ in vm.clearError() })
            ) { Button("OK", role: .cancel) { } } message: {
                Text(vm.errorMessage ?? "")
            }
            
            // --- Dismiss when authenticated -----------------------------------
            .onChange(of: vm.isAuthenticated) { _, newValue in
                if newValue { dismiss() }
            }
            
            .navigationTitle("Login")
        }
    }
}


// MARK: - Preview
#Preview {
    let auth = MockAuthService()
    LoginView(authService: auth)
}

RegisterView.swift
WH40KBuilds/Presentation/Auth/Views/RegisterView

//
//  RegisterView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//


import SwiftUI

struct RegisterView: View {
    
    @StateObject private var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Focus management
    @FocusState private var focusedField: Field?
    enum Field { case email, password, confirm }
    
    // Confirm password local
    @State private var confirmPass: String = ""
    
    // MARK: - Init
    init(authService: AuthService = FirebaseAuthService()) {
        _vm = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkerboard")
                        .resizable()
                        .frame(width: 64, height: 64)
                    Text("Create Account")
                        .font(.largeTitle).bold()
                }
                .padding(.bottom, 32)
                
                // Email & passwords
                Group {
                    TextField("E‑mail", text: $vm.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                    
                    SecureField("Password (min 6 chars)", text: $vm.password)
                        .textContentType(.newPassword)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .password)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .confirm }
                    
                    SecureField("Confirm Password", text: $confirmPass)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .confirm)
                        .submitLabel(.continue)     // 👉 Continue
                        .onSubmit { callRegister() } // 👉 llama register
                }
                
                // Register button
                Button(action: callRegister) {
                    if vm.isLoading {
                        ProgressView()
                    } else {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.isLoading
                          || vm.email.isEmpty
                          || vm.password.isEmpty
                          || confirmPass.isEmpty)
                
                // Back to login
                Button("Back to Login") { dismiss() }
                    .font(.footnote)
            }
            .padding()
            
            // Oculta teclado al tocar afuera
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
            
            // Alert de error / mensaje
            .alert("Message",
                   isPresented: Binding(
                       get: { vm.errorMessage != nil },
                       set: { _ in vm.clearError() })
            ) { Button("OK", role: .cancel) { } } message: {
                Text(vm.errorMessage ?? "")
            }
            
            // Cierra en registro correcto
            .onChange(of: vm.isAuthenticated) { _, newValue in
                if newValue { dismiss() }
            }
            .navigationTitle("Register")
        }
    }
    
    // MARK: - Helper
    private func callRegister() {
        if vm.password == confirmPass {
            vm.register()
        } else {
            vm.showError("Passwords do not match.")
        }
    }
}

// MARK: - Preview
#Preview {
    let auth = MockAuthService()
    RegisterView(authService: auth)
}

BuildDetailViewModel.swift
WH40KBuilds/Presentation/Builds/Detail/ViewModels/BuildDetailViewModel

//
//  BuildDetailViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

@MainActor
final class BuildDetailViewModel: ObservableObject {
    @Published var build: Build
    @Published var errorMessage: String?
    @Published var showingError: Bool = false
    
    private let repo: BuildRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(build: Build, repo: BuildRepository) {
        self.build = build
        self.repo  = repo
    }
    
    func saveChanges() {
        repo.updateBuild(build)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage  = error.localizedDescription
                    self?.showingError = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
}

BuildDetailView.swift
WH40KBuilds/Presentation/Builds/Detail/Views/BuildDetailView

//
//  BuildDetailView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildDetailView: View {
    
    // Binding: la vista madre (lista) pasa $build
    @Binding var build: Build
    
    // Dependencias
    let repository: BuildRepository
    @EnvironmentObject private var session: SessionStore
    
    // Navegación al editor
    @State private var showEdit = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Encabezado
                Text(build.name)
                    .font(.largeTitle).bold()
                
                // Faction / Detachment
                HStack {
                    VStack(alignment: .leading) {
                        Text("Faction:")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(build.faction.name)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Detachment:")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(build.detachmentType)
                    }
                }
                
                // Puntos
                HStack {
                    statChip("CP", value: build.commandPoints)
                    statChip("Pts", value: build.totalPoints)
                }
                
                Divider()
                
                // Slots (solo resumen)
                slotRow("HQ", build.slots.hq)
                slotRow("Troops", build.slots.troops)
                slotRow("Elite", build.slots.elite)
                slotRow("Fast Attack", build.slots.fastAttack)
                slotRow("Heavy", build.slots.heavySupport)
                slotRow("Flyers", build.slots.flyers)
                
                // Notas
                if let notes = build.notes, !notes.isEmpty {
                    Divider()
                    Text("Notes")
                        .font(.headline)
                    Text(notes)
                }
            }
            .padding()
        }
        .navigationTitle("Build Detail")
        .toolbar {
            // Botón Edit
            Button("Edit") { showEdit = true }
        }
        // Push a pantalla completa
        .navigationDestination(isPresented: $showEdit) {
            BuildEditView(
                build: $build,
                repository: repository,
                session: session
            )
        }
    }
    
    // MARK: - Helper views
    private func statChip(_ label: String, value: Int) -> some View {
        VStack {
            Text("\(value)")
                .font(.title2).bold()
            Text(label).font(.caption)
        }
        .padding(8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func slotRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
        }
    }
}

// MARK: - Preview
#Preview {
    let session = SessionStore(service: MockAuthService())
    NavigationStack {
        BuildDetailView(
            build: .constant(
                Build(id: "1",
                      name: "Sample",
                      faction: .init(name: "Ultramarines", subfaction: nil),
                      detachmentType: "Battalion",
                      commandPoints: 6,
                      totalPoints: 2000,
                      slots: .init(hq: 2, troops: 3, elite: 2,
                                   fastAttack: 1, heavySupport: 2, flyers: 0),
                      units: [], stratagems: [],
                      notes: "Preview notes",
                      createdBy: "uid", createdAt: .now)
            ),
            repository: MockBuildRepository()
        )
    }
    .environmentObject(session)
}

BuildEditView.swift
WH40KBuilds/Presentation/Builds/Edit/Views/BuildEditView

//
//  BuildEditView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildEditView: View {
    
    // Binding al objeto de origen
    @Binding var build: Build
    
    // ViewModel
    @StateObject private var vm: BuildEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Focus control
    @FocusState private var focused: Field?
    enum Field {
        case name, faction, subfaction, detachment, cp, tp
    }
    
    // MARK: - Init
    init(build: Binding<Build>,
         repository: BuildRepository,
         session: SessionStore) {
        self._build = build
        _vm = StateObject(wrappedValue:
            BuildEditViewModel(build: build.wrappedValue,
                               repository: repository,
                               session: session)
        )
    }
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Build Info") {
                TextField("Name", text: $vm.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focused = .faction }
                
                TextField("Faction", text: $vm.faction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .faction)
                    .submitLabel(.next)
                    .onSubmit { focused = .subfaction }
                
                TextField("Subfaction", text: $vm.subfaction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .subfaction)
                    .submitLabel(.next)
                    .onSubmit { focused = .detachment }
                
                TextField("Detachment", text: $vm.detachmentType)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .detachment)
                    .submitLabel(.next)
                    .onSubmit { focused = .cp }
            }
            
            Section("Points") {
                TextField("Command Points", text: $vm.commandPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .cp)
                    .submitLabel(.next)
                    .onSubmit { focused = .tp }
                
                TextField("Total Points", text: $vm.totalPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .tp)
                    .submitLabel(.continue)
                    .onSubmit { vm.save() }
            }
            Section {
                Button {
                    vm.save()
                } label: {
                    if vm.isSaving { ProgressView() }
                    else { Text("Save").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
            
        }
        .navigationTitle("Edit Build")
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }   // Oculta teclado
        .alert("Error",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { _ in vm.clearError() })
        ) { Button("OK", role: .cancel) { } } message: {
            Text(vm.errorMessage ?? "")
        }
        // Actualiza binding y cierra
        .onChange(of: vm.saveSuccess) { _, newValue in
            if newValue, let edited = vm.updatedBuild {
                build = edited
                dismiss()
            }
        }
    }
}

BuildEditViewModel.swift
WH40KBuilds/Presentation/Builds/Edit/ViewModels/BuildEditViewModel

//
//  BuildEditViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

@MainActor
final class BuildEditViewModel: ObservableObject {
    
    // MARK: - Inputs (bind con la vista)
    @Published var name: String
    @Published var faction: String
    @Published var subfaction: String
    @Published var detachmentType: String
    @Published var commandPoints: String
    @Published var totalPoints: String
    
    // MARK: - State
    @Published private(set) var formState: BuildFormState = .init(isValid: false)
    @Published private(set) var isSaving  = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    /// Copia editada que se devuelve al cerrar la vista
    private(set) var updatedBuild: Build?
    
    // MARK: - Dependencies
    private let repository: BuildRepository
    private let session: SessionStore
    private let validator = ValidateBuildFormUseCase()
    private let originalBuild: Build
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(build: Build,
         repository: BuildRepository,
         session: SessionStore) {
        
        self.originalBuild = build
        self.repository    = repository
        self.session       = session
        
        // Rellenar campos iniciales
        self.name           = build.name
        self.faction        = build.faction.name
        self.subfaction     = build.faction.subfaction ?? ""
        self.detachmentType = build.detachmentType
        self.commandPoints  = "\(build.commandPoints)"
        self.totalPoints    = "\(build.totalPoints)"
        
        bindValidation()
    }
    
    // MARK: - Validación reactiva
    private func bindValidation() {
        Publishers.CombineLatest4($name, $faction, $commandPoints, $totalPoints)
            .map { [validator] in
                validator.validate(name: $0,
                                   faction: $1,
                                   commandPoints: $2,
                                   totalPoints: $3)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$formState)
    }
    
    // MARK: - Acciones ------------------------------------------------------
    func save() {
        guard formState.isValid,
              let cp = Int(commandPoints),
              let tp = Int(totalPoints) else { return }
        
        isSaving = true
        
        let edited = Build(
            id: originalBuild.id,
            name: name,
            faction: .init(name: faction,
                           subfaction: subfaction.isEmpty ? nil : subfaction),
            detachmentType: detachmentType,
            commandPoints: cp,
            totalPoints: tp,
            slots: originalBuild.slots,
            units: originalBuild.units,
            stratagems: originalBuild.stratagems,
            notes: originalBuild.notes,
            createdBy: originalBuild.createdBy,
            createdAt: originalBuild.createdAt
        )
        
        repository.updateBuild(edited)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.updatedBuild = edited   // para el Binding en la vista
                self?.saveSuccess = true      // dispara dismiss en la vista
            }
            .store(in: &cancellables)
    }
    
    func clearError() {
        errorMessage = nil
    }
}

BuildFormViewModel.swift
WH40KBuilds/Presentation/Builds/Form/ViewModels/BuildFormViewModel

//
//  BuildFormViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation
import Combine

@MainActor
final class BuildFormViewModel: ObservableObject {
    
    // Form fields
    @Published var name = ""
    @Published var faction = ""
    @Published var subfaction = ""
    @Published var detachmentType = ""
    @Published var commandPoints = ""
    @Published var totalPoints = ""
    
    // Validation + state
    @Published private(set) var formState   = BuildFormState(isValid: false)
    @Published private(set) var isSaving    = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    // Dependencies
    private let repo: BuildRepository
    private let session: SessionStore
    private let validator = ValidateBuildFormUseCase()
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: BuildRepository,
         session: SessionStore) {
        self.repo = repository
        self.session = session
        bindValidation()
    }
    
    private func bindValidation() {
        Publishers.CombineLatest4($name, $faction, $commandPoints, $totalPoints)
            .map { [validator] in
                validator.validate(name: $0, faction: $1,
                                   commandPoints: $2, totalPoints: $3)
            }
            .assign(to: &$formState)
    }
    
    // MARK: - Save
    func saveBuild() {
        guard formState.isValid,
              let cp = Int(commandPoints),
              let tp = Int(totalPoints) else { return }
        
        let build = Build(
            id: nil,
            name: name,
            faction: .init(name: faction, subfaction: subfaction),
            detachmentType: detachmentType,
            commandPoints: cp,
            totalPoints: tp,
            slots: .init(hq: 0, troops: 0, elite: 0,
                         fastAttack: 0, heavySupport: 0, flyers: 0),
            units: [],
            stratagems: [],
            notes: nil,
            createdBy: session.uid ?? "unknown",
            createdAt: Date()
        )
        
        isSaving = true
        
        repo.addBuild(build)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.saveSuccess = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func clearError() { errorMessage = nil }
}

BuildFormView.swift
WH40KBuilds/Presentation/Builds/Form/Views/BuildFormView

//
//  BuildFormView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct BuildFormView: View {
    @StateObject private var vm: BuildFormViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    // Focus management
    @FocusState private var focusedField: Field?
    enum Field {
        case name, faction, subfaction, detachment, commandPoints, totalPoints
    }
    
    // MARK: – Init
    init(repository: BuildRepository = FirestoreBuildRepository(),
         session: SessionStore) {
        _vm = StateObject(wrappedValue: BuildFormViewModel(
            repository: repository,
            session: session
        ))
    }
    
    // MARK: – Body
    var body: some View {
        Form {
            Section("Build Info") {
                TextField("Name", text: $vm.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .faction }
                
                TextField("Faction", text: $vm.faction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .faction)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .subfaction }
                
                TextField("Subfaction", text: $vm.subfaction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .subfaction)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .detachment }
                
                TextField("Detachment Type", text: $vm.detachmentType)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .detachment)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .commandPoints }
            }
            
            Section("Points") {
                TextField("Command Points", text: $vm.commandPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .commandPoints)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .totalPoints }
                
                TextField("Total Points", text: $vm.totalPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .totalPoints)
                    .submitLabel(.continue)
                    .onSubmit { vm.saveBuild() }
            }
            
            Section {
                Button {
                    vm.saveBuild()
                } label: {
                    if vm.isSaving { ProgressView() }
                    else { Text("Save Build").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
        }
        .navigationTitle("New Build")
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }
        .alert("Message",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { _ in vm.clearError() })
        ) { Button("OK", role: .cancel) { } } message: {
            Text(vm.errorMessage ?? "")
        }
        
        .onChange(of: vm.saveSuccess) { _, newValue in
            if newValue { dismiss() }
        }
    }
}

// MARK: – Preview
#Preview {
    let session = SessionStore(service: MockAuthService())
    BuildFormView(
        repository: MockBuildRepository(),
        session: session
    )
    .environmentObject(session)
}

BuildListViewModel.swift
WH40KBuilds/Presentation/Builds/List/ViewModels/BuildListViewModel

//
//  BuildListViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

import Foundation
import Combine

@MainActor
final class BuildListViewModel: ObservableObject {
    
    // MARK: - Published state
    @Published var builds: [Build] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Deps
    private let repository: BuildRepository
    private let session: SessionStore
    
    private var cancellables = Set<AnyCancellable>()
    private var firestoreCancellable: AnyCancellable?
    
    // MARK: - Init
    init(repository: BuildRepository, session: SessionStore) {
        self.repository = repository
        self.session    = session
        bindSession()
    }
    
    // Escucha el cambio de uid
    private func bindSession() {
        session.$authState
            .map { state -> String? in
                if case let .signedIn(user) = state { return user.uid }
                return nil
            }
            .removeDuplicates()
            .sink { [weak self] uid in
                guard let self else { return }
                
                firestoreCancellable?.cancel()
                builds = []
                
                if let uid {
                    subscribeToBuilds(for: uid)
                }
            }
            .store(in: &cancellables)
    }
    
    // Listener Firestore → publisher Combine
    private func subscribeToBuilds(for uid: String) {
        isLoading = true
        
        firestoreCancellable = repository.fetchBuilds(for: uid)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                // Sólo manejamos errores aquí
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] builds in
                self?.isLoading = false
                self?.builds = builds
            }
    }
        
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let id = builds[index].id else { return }
            repository.deleteBuild(id: id)
                .sink(receiveCompletion: { _ in }, receiveValue: { })
                .store(in: &cancellables)
        }
    }
}

BuildListView.swift
WH40KBuilds/Presentation/Builds/List/Views/BuildListView

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

MockBuildRepository.swift
WH40KBuilds/Presentation/Builds/List/PreviewHelpers/MockBuildRepository

//
//  MockBuildRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

final class MockBuildRepository: BuildRepository {
  
    var builds: [Build] = []
    
    private let addSampleBuilds: [Build] = [
        Build(
            id: "PREVIEW‑1",
            name: "Ultramarines Alpha",
            faction: .init(name: "Ultramarines", subfaction: "2nd Company"),
            detachmentType: "Battalion",
            commandPoints: 6,
            totalPoints: 2000,
            slots: .init(hq: 2, troops: 3, elite: 2, fastAttack: 1, heavySupport: 2, flyers: 0),
            units: [],
            stratagems: [],
            notes: "Preview Build A",
            createdBy: "PreviewUser",
            createdAt: Date()
        )
    ]
    
    func addMockBuild() {
        if let sample = addSampleBuilds.first {
            builds.append(sample)
        }
    }
    
    func fetchBuilds(for uid: String) -> AnyPublisher<[Build], any Error> {
        Just(addSampleBuilds)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addBuild(_ build: Build) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateBuild(_ build: Build) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteBuild(id: String) -> AnyPublisher<Void, Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
}
*/
