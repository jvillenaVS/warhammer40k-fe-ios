//
//  BuildEditViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class BuildEditViewModel: ObservableObject {
    
    // ───────── Form fields
    @Published var name: String
    @Published var faction: String
    @Published var subfaction: String
    @Published var detachmentType: String
    @Published var commandPoints: String
    @Published var totalPoints: String
    
    @Published var hq:     String
    @Published var troops: String
    @Published var elite:  String
    @Published var fast:   String
    @Published var heavy:  String
    @Published var flyers: String
    
    // ───────── Codex
    @Published private(set) var detachments: [DetachmentCodex] = []
    @Published var selectedDetachment: DetachmentCodex?
    
    // ───────── State
    @Published private(set) var formState = BuildFormState(isValid: false)
    @Published private(set) var isSaving  = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    private(set) var updatedBuild: Build?
    
    // ───────── Deps
    private let repository: BuildRepository
    private let codex: CodexRepository
    private let session: SessionStore?
    private let validator = ValidateBuildForm()
    
    private let original: Build
    private var cancellables = Set<AnyCancellable>()
    
    // ───────── Init
    init(build: Build,
         repository: BuildRepository,
         codex: CodexRepository = FirestoreCodexRepository(),
         session: SessionStore) {
        
        self.original   = build
        self.repository = repository
        self.codex      = codex
        self.session    = session
        
        // Rellenar campos
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
        loadDetachments()
    }
    
    // ───────── Validation
    private func bindValidation() {
        let basic = Publishers.CombineLatest3($name, $faction, $subfaction)
        let pts   = Publishers.CombineLatest3($detachmentType, $commandPoints, $totalPoints)
        let slotA = Publishers.CombineLatest3($hq, $troops, $elite)
        let slotB = Publishers.CombineLatest3($fast, $heavy, $flyers)
        
        basic
            .combineLatest(pts, slotA, slotB)
            .map { [weak self] b, p, a, b2 -> BuildFormState in
                let (n, fac, subfac) = b
                let (det, cp, tp)    = p
                let (hq, tr, el)     = a
                let (fa, he, fl)     = b2
                
                let vals = FormValues(
                    name: n, faction: fac, subfaction: subfac,
                    detachment: det,
                    cp: cp, points: tp,
                    slots: [
                        .hq     : hq,
                        .troops : tr,
                        .elite  : el,
                        .fast   : fa,
                        .heavy  : he,
                        .flyers : fl
                    ]
                )
                return self?.validator
                    .validate(values: vals,
                              detachment: self?.selectedDetachment) ?? .init(isValid: false)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$formState)
    }
    
    // ───────── Codex (detachments)
    private func loadDetachments() {
        codex.detachments(edition: "10e", faction: original.faction.name)
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dets in
                self?.detachments = dets
                // match el detachment actual, si existe
                self?.selectedDetachment =
                    dets.first { $0.name == self?.detachmentType }
            }
            .store(in: &cancellables)
    }
    
    // ───────── Save
    func editBuild() {
        guard formState.isValid,
              let cp  = Int(commandPoints),
              let pts = Int(totalPoints) else { return }
        
        isSaving = true
        
        let edited = Build(
            id: original.id,
            name: name,
            faction: .init(name: faction,
                           subfaction: subfaction.isEmpty ? nil : subfaction),
            detachmentType: detachmentType,
            commandPoints: cp,
            totalPoints: pts,
            slots: .init(hq: Int(hq) ?? 0,
                         troops: Int(troops) ?? 0,
                         elite: Int(elite) ?? 0,
                         fastAttack: Int(fast) ?? 0,
                         heavySupport: Int(heavy) ?? 0,
                         flyers: Int(flyers) ?? 0),
            units: original.units,
            stratagems: original.stratagems,
            notes: original.notes,
            createdBy: original.createdBy,
            createdAt: original.createdAt
        )
        
        repository.updateBuild(edited)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comp in
                self?.isSaving = false
                if case .failure(let e) = comp {
                    self?.errorMessage = e.localizedDescription
                } else {
                    self?.updatedBuild = edited
                    self?.saveSuccess = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func clearError() { errorMessage = nil }
}
