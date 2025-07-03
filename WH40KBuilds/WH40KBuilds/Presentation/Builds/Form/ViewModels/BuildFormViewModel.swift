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
    
    // MARK: – Published fields
    @Published var name           = ""
    @Published var faction        = ""
    @Published var subfaction     = ""
    @Published var detachmentType = ""
    @Published var commandPoints  = ""
    @Published var totalPoints    = ""
    
    // Slots
    @Published var hq       = ""
    @Published var troops   = ""
    @Published var elite    = ""
    @Published var fast     = ""
    @Published var heavy    = ""
    @Published var flyers   = ""
    
    // MARK: – State
    @Published private(set) var formState   = BuildFormState(isValid: false)
    @Published private(set) var isSaving    = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    // MARK: – Deps
    private let repo: BuildRepository
    private let session: SessionStore
    private let validator = ValidateBuildForm()
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: BuildRepository, session: SessionStore) {
        self.repo     = repository
        self.session  = session
        bindValidation()
    }
    
    // MARK: – Combine validation
    private func bindValidation() {
        // 3 grupos de CombineLatest3  →   ((A,B,C),(D,E,F),(G,H,I))
        let group1 = Publishers.CombineLatest3($name, $faction, $subfaction)
        let group2 = Publishers.CombineLatest3($detachmentType, $commandPoints, $totalPoints)
        let group3 = Publishers.CombineLatest3($hq, $troops, $elite)        // primeros 3 slots
        let group4 = Publishers.CombineLatest3($fast, $heavy, $flyers)      // otros 3
        
        Publishers.CombineLatest4(group1, group2, group3, group4)
            .map { [validator] g1, g2, g3, g4 -> BuildFormState in
                let (n,f,s)           = g1
                let (det,cp,tp)       = g2
                let (hq,troops,elite) = g3
                let (fast,heavy,fly)  = g4
                
                let values = FormValues(
                    name: n, faction: f, subfaction: s,
                    detachment: det,
                    cp: cp, points: tp,
                    slots: [
                        (.hq, hq), (.troops, troops), (.elite, elite),
                        (.fast, fast), (.heavy, heavy), (.flyers, fly)
                    ]
                )
                return validator.validate(values: values)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$formState)
    }
    
    // MARK: – Public save
    func saveBuild() {
        // Valida con el último estado
        guard formState.isValid,
              let cp  = Int(commandPoints),
              let pts = Int(totalPoints),
              let hqI = Int(hq), let trI = Int(troops), let elI = Int(elite),
              let faI = Int(fast), let heI = Int(heavy), let flI = Int(flyers)
        else {
            errorMessage = "Please complete all fields correctly."
            return
        }
        
        let build = Build(
            id: nil,
            name: name,
            faction: .init(name: faction, subfaction: subfaction),
            detachmentType: detachmentType,
            commandPoints: cp,
            totalPoints: pts,
            slots: .init(hq: hqI, troops: trI, elite: elI,
                         fastAttack: faI, heavySupport: heI, flyers: flI),
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
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                } else {
                    self?.saveSuccess = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func clearError() { errorMessage = nil }
}

// MARK: – Helper struct for validator
struct FormValues {
    let name, faction, subfaction, detachment: String
    let cp, points: String
    /// Tupla (campo, valor)
    let slots: [(BuildFormState.Field, String)]
}
