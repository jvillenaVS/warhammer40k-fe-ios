//
//  BuildFormViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 1/7/25.
//

import Combine
import Foundation

@MainActor
final class BuildFormViewModel: ObservableObject {
    
    // MARK: – Form fields ---------------------------------------------------
    @Published var name           = ""
    @Published var subfaction     = ""
    @Published var commandPoints  = ""
    @Published var totalPoints    = ""
    
    @Published var hq     = ""
    @Published var troops = ""
    @Published var elite  = ""
    @Published var fast   = ""
    @Published var heavy  = ""
    @Published var flyers = ""
    
    // MARK: – Codex data ----------------------------------------------------
    @Published private(set) var factions:     [FactionCodex]     = []
    @Published          var selectedFaction: FactionCodex?       = nil
    
    @Published private(set) var detachments:  [DetachmentCodex]  = []
    @Published          var selectedDetachment: DetachmentCodex? = nil
    
    @Published private(set) var subFactions: [SubFactionCodex] = []
    @Published          var selectedSubFaction: SubFactionCodex? = nil
    
    @Published var detachmentType = ""
    
    // MARK: – Validation ----------------------------------------------------
    @Published private(set) var formState   = BuildFormState(isValid: false)
    @Published private(set) var isSaving    = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    // MARK: – Deps
    private let repository:   BuildRepository
    private let codex:  CodexRepository
    private(set) var session: SessionStore?
    private let validator = ValidateBuildForm()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: – Init
    init(repository: BuildRepository,
         codex: CodexRepository) {
        
        self.repository  = repository
        self.codex = codex
        
        bindValidation()
        loadFactions()
        bindSubFactionCascade()
        bindDetachmentCascade()
    }
    
    // MARK: – Carga de facciones
    private func loadFactions() {
        codex.factions(edition: "10e")
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fac in
                self?.factions = fac
                // ⤵︎ Auto‑selección de la primera facción
                if self?.selectedFaction == nil,
                   let first = fac.first {
                    self?.selectedFaction = first
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: – Cascada facción ➜ detachments
    private func bindDetachmentCascade() {
        
        $selectedFaction
            .compactMap { $0 }
            .flatMap { [codex] (fac: FactionCodex) -> AnyPublisher<[DetachmentCodex], Never> in
                codex.detachments(edition: "10e", faction: fac.docID)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] dets in
                self?.detachments = dets
                if let first = dets.first {
                    self?.selectedDetachment = first
                    self?.detachmentType     = first.name
                } else {
                    self?.selectedDetachment = nil
                    self?.detachmentType     = "Not Available"
                }
            }
            .store(in: &cancellables)
        
        $selectedDetachment
            .map { $0?.name ?? "" }
            .assign(to: &$detachmentType)
    }
    
    private func bindSubFactionCascade() {
        
        $selectedFaction
            .compactMap { $0 }
            .flatMap { [codex] (fac: FactionCodex) -> AnyPublisher<[SubFactionCodex], Never> in
                codex.subFactions(edition: "10e", faction: fac.docID)
                     .replaceError(with: [])
                     .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] subs in
                self?.subFactions = subs
                if let first = subs.first {
                    self?.selectedSubFaction = first
                    self?.subfaction = first.name
                } else {
                    self?.selectedSubFaction = nil
                    self?.subfaction         = "Not Available"
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: – Validación reactiva (nombre, facción, puntos, slots…)
    private func bindValidation() {
        let basic = Publishers.CombineLatest3($name,
                                              $selectedFaction.map { $0?.name ?? "" },
                                              $subfaction)
        let pts   = Publishers.CombineLatest3($detachmentType,
                                              $commandPoints,
                                              $totalPoints)
        let slotA = Publishers.CombineLatest3($hq, $troops, $elite)
        let slotB = Publishers.CombineLatest3($fast, $heavy, $flyers)
        
        basic
            .combineLatest(pts, slotA, slotB)
            .map { [validator, weak self] b, p, s1, s2 -> BuildFormState in
                let (n, fac, sub) = b
                let (det, cp, tp) = p
                let (hq, tr, el)  = s1
                let (fa, he, fl)  = s2
                
                let vals = FormValues(
                    name: n, faction: fac, subfaction: sub,
                    detachment: det,
                    cp: cp, points: tp,
                    slots: [
                        .hq     : hq, .troops : tr, .elite  : el,
                        .fast   : fa, .heavy  : he, .flyers : fl
                    ])
                
                return validator
                    .validate(values: vals,
                              detachment: self?.selectedDetachment)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$formState)
    }
    
    // MARK: – Save
    func saveBuild() {
        guard formState.isValid,
              let faction = selectedFaction,
              let cp      = Int(commandPoints),
              let pts     = Int(totalPoints) else { return }
        
        isSaving = true
        
        let build = Build(
            id: nil,
            name: name,
            faction: .init(name: faction.name, subfaction: subfaction),
            detachmentType: detachmentType,
            commandPoints: cp,
            totalPoints: pts,
            slots: .init(hq: Int(hq) ?? 0,
                         troops: Int(troops) ?? 0,
                         elite: Int(elite) ?? 0,
                         fastAttack: Int(fast) ?? 0,
                         heavySupport: Int(heavy) ?? 0,
                         flyers: Int(flyers) ?? 0),
            units: [],
            stratagems: [],
            notes: nil,
            createdBy: session?.uid ?? "unknown",
            createdAt: Date()
        )
        
        repository.addBuild(build)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comp in
                self?.isSaving = false
                if case .failure(let e) = comp {
                    self?.errorMessage = e.localizedDescription
                } else {
                    self?.saveSuccess = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func attachSession(_ session: SessionStore) {
        self.session = session
    }
    
    func clearError() { errorMessage = nil }
}
