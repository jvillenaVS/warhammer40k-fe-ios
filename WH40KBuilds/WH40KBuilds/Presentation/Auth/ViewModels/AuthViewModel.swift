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
