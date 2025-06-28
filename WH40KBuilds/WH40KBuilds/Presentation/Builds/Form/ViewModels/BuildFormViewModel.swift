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
    
    // Input fields
    @Published var name = ""
    @Published var faction = ""
    @Published var subfaction = ""
    @Published var detachmentType = ""
    @Published var commandPoints = ""
    @Published var totalPoints = ""
    
    // Output
    @Published private(set) var formState = BuildFormState(isValid: false)
    @Published var isSaving = false
    @Published var saveSuccess = false
    @Published var errorMessage: String?
    
    private let repo: BuildRepository
    private let validator = ValidateBuildFormUseCase()
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: BuildRepository) {
        self.repo = repository
        bindValidation()
    }
    
    /// Observa cambios de los campos y valida
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
            units: [], stratagems: [],
            notes: nil, createdBy: "local-user",
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
}
