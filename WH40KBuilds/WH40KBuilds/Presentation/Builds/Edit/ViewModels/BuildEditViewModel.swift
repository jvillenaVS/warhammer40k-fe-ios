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
    
    // ── Inputs (bind con la vista) ──────────────────────────────────────
    @Published var name: String
    @Published var faction: String
    @Published var subfaction: String
    @Published var detachmentType: String
    @Published var commandPoints: String
    @Published var totalPoints: String
    
    // Slots
    @Published var hq: String
    @Published var troops: String
    @Published var elite: String
    @Published var fast: String
    @Published var heavy: String
    @Published var flyers: String
    
    // ── State ──────────────────────────────────────────────────────────
    @Published private(set) var formState   = BuildFormState(isValid: false)
    @Published private(set) var isSaving    = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    /// Copia resultante que se devuelve al cerrar
    private(set) var updatedBuild: Build?
    
    // ── Dependencias ───────────────────────────────────────────────────
    private let repository: BuildRepository
    private let session: SessionStore
    private let validator = ValidateBuildForm()
    private let originalBuild: Build
    private var cancellables = Set<AnyCancellable>()
    
    // ── Init ───────────────────────────────────────────────────────────
    init(build: Build,
         repository: BuildRepository,
         session: SessionStore) {
        
        self.originalBuild = build
        self.repository    = repository
        self.session       = session
        
        // ① Rellena campos
        self.name           = build.name
        self.faction        = build.faction.name
        self.subfaction     = build.faction.subfaction ?? ""
        self.detachmentType = build.detachmentType
        self.commandPoints  = "\(build.commandPoints)"
        self.totalPoints    = "\(build.totalPoints)"
        
        self.hq     = "\(build.slots.hq)"
        self.troops = "\(build.slots.troops)"
        self.elite  = "\(build.slots.elite)"
        self.fast   = "\(build.slots.fastAttack)"
        self.heavy  = "\(build.slots.heavySupport)"
        self.flyers = "\(build.slots.flyers)"
        
        bindValidation()
    }
    
    // ── Validación reactiva (6 + 6) ────────────────────────────────────
    private func bindValidation() {
        let g1 = Publishers.CombineLatest3($name, $faction, $subfaction)
        let g2 = Publishers.CombineLatest3($detachmentType, $commandPoints, $totalPoints)
        let g3 = Publishers.CombineLatest3($hq, $troops, $elite)
        let g4 = Publishers.CombineLatest3($fast, $heavy, $flyers)
        
        Publishers.CombineLatest4(g1, g2, g3, g4)
            .map { [validator] g1, g2, g3, g4 in
                let (n,f,s)         = g1
                let (det,cp,tp)     = g2
                let (hq,tr,el)      = g3
                let (fa,he,fl)      = g4
                
                let vals = FormValues(
                    name: n, faction: f, subfaction: s,
                    detachment: det,
                    cp: cp, points: tp,
                    slots: [
                        (.hq, hq), (.troops, tr), (.elite, el),
                        (.fast, fa), (.heavy, he), (.flyers, fl)
                    ]
                )
                return validator.validate(values: vals)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$formState)
    }
    
    // ── Acciones ───────────────────────────────────────────────────────
    func editBuild() {
        // Valida última foto del formulario
        guard formState.isValid,
              let cp  = Int(commandPoints),
              let pts = Int(totalPoints),
              let hqI = Int(hq), let trI = Int(troops), let elI = Int(elite),
              let faI = Int(fast), let heI = Int(heavy), let flI = Int(flyers)
        else {
            errorMessage = "Please correct the highlighted fields."
            return
        }
        
        let edited = Build(
            id: originalBuild.id,
            name: name,
            faction: .init(name: faction, subfaction: subfaction.isEmpty ? nil : subfaction),
            detachmentType: detachmentType,
            commandPoints: cp,
            totalPoints: pts,
            slots: .init(hq: hqI, troops: trI, elite: elI,
                         fastAttack: faI, heavySupport: heI, flyers: flI),
            units: originalBuild.units,
            stratagems: originalBuild.stratagems,
            notes: originalBuild.notes,
            createdBy: originalBuild.createdBy,
            createdAt: originalBuild.createdAt
        )
        
        isSaving = true
        repository.updateBuild(edited)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let err) = completion {
                    self?.errorMessage = err.localizedDescription
                } else {
                    self?.updatedBuild = edited
                    self?.saveSuccess  = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func clearError() { errorMessage = nil }
}
