//
//  LoginView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: Field?
    enum Field { case email, password }
    
    init(authService: AuthService = FirebaseAuthService()) {
        _vm = StateObject(wrappedValue: AuthViewModel(authService: authService))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkerboard")
                        .resizable()
                        .frame(width: 64, height: 64)
                    Text("WH40K Builder")
                        .font(.largeTitle).bold()
                }
                .padding(.bottom, 32)
                
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
                
                GoogleSignInButton {
                    guard let rootVC =  UIApplication.topViewController() else {
                        print("❌ No root view controller found")
                        return
                    }
                    vm.signInWithGoogle(presenting: rootVC)
                }
                .frame(height: 48)
                .padding(.top, 4)
                
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
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
           
            .alert("Message",
                   isPresented: Binding(
                       get: { vm.errorMessage != nil },
                       set: { _ in vm.clearError() })
            ) { Button("OK", role: .cancel) { } } message: {
                Text(vm.errorMessage ?? "")
            }

            .onChange(of: vm.isAuthenticated) { _, newValue in
                if newValue { dismiss() }
            }
            
            .navigationTitle("Login")
        }
    }
}


#Preview {
    let auth = MockAuthService()
    LoginView(authService: auth)
}
