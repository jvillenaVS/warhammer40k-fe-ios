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

