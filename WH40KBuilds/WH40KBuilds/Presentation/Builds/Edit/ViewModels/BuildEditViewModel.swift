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
