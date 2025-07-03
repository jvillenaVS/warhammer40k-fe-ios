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
                        .submitLabel(.continue)
                        .onSubmit { callRegister() }
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


