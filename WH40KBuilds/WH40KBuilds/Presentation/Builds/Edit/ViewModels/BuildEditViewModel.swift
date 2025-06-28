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
    
    // Campos editables como @Published
    @Published var name: String
    @Published var detachmentType: String
    @Published var commandPoints: String   // String para TextField binding
    @Published var totalPoints: String
    @Published var notes: String
    
    // Dependencias
    private let repo: BuildRepository
    private var cancellables = Set<AnyCancellable>()
    private var originalBuild: Build
    
    // Alertas
    @Published var errorMessage: String?
    @Published var showAlert = false
    @Published var dismiss = false         // Para cerrar la vista al guardar
    
    init(build: Build, repo: BuildRepository) {
        self.originalBuild = build
        self.repo = repo
        
        // Rellenar con valores existentes
        self.name = build.name
        self.detachmentType = build.detachmentType
        self.commandPoints = String(build.commandPoints)
        self.totalPoints = String(build.totalPoints)
        self.notes = build.notes ?? ""
    }
    
    func save() {
        guard
            let cp = Int(commandPoints),
            let points = Int(totalPoints)
        else {
            errorMessage = "CP and Points must be numeric."
            showAlert = true
            return
        }
        
        var edited = originalBuild
        edited.name = name
        edited.detachmentType = detachmentType
        edited.commandPoints = cp
        edited.totalPoints = points
        edited.notes = notes
        
        repo.updateBuild(edited)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                    self?.showAlert = true
                } else {
                    self?.dismiss = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
}
