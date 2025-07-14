//
//  BuildFormViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 1/7/25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class BuildFormViewModel: ObservableObject {
    
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
    
    @Published var editions: [EditionCodex] = []
    @Published var selectedEdition: EditionCodex? = nil
    
    @Published private(set) var factions:     [FactionCodex]     = []
    @Published          var selectedFaction: FactionCodex?       = nil
    
    @Published private(set) var detachments:  [DetachmentCodex]  = []
    @Published          var selectedDetachment: DetachmentCodex? = nil
    
    @Published private(set) var subFactions: [SubFactionCodex] = []
    @Published          var selectedSubFaction: SubFactionCodex? = nil
    
    @Published var detachmentType = ""
    
    @Published private(set) var formState   = BuildFormState(isValid: false)
    @Published private(set) var isSaving    = false
    @Published private(set) var saveSuccess = false
    @Published private(set) var errorMessage: String?
    
    private let repository:   BuildRepository
    private let codex:  CodexRepository
    private(set) var session: SessionStore?
    private let validator = ValidateBuildForm()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: BuildRepository,
         codex: CodexRepository) {
        
        self.repository  = repository
        self.codex = codex
        
        bindValidation()
        loadEditions()
        bindFactionCascade()
        bindSubFactionCascade()
        bindDetachmentCascade()
    }
    
    private func loadEditions() {
        codex.editions()
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] editions in
                self?.editions = editions
                if let first = editions.first {
                    self?.selectedEdition = first
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindFactionCascade() {
        $selectedEdition
            .compactMap { $0?.id }
            .removeDuplicates()
            .flatMap { [codex] editionId in
                codex.factions(edition: editionId)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] factions in
                self?.factions = factions
                if let first = factions.first {
                    self?.selectedFaction = first
                } else {
                    self?.selectedFaction = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindDetachmentCascade() {
        $selectedFaction
            .compactMap { $0 }
            .flatMap { [codex] fac -> AnyPublisher<[DetachmentCodex], Never> in
                guard let editionId = fac.editionId else {
                    return Just([DetachmentCodex]()).eraseToAnyPublisher()
                }
                return codex.detachments(edition: editionId, faction: fac.docID)
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
            .flatMap { [codex] fac in
                guard let editionId = fac.editionId else {
                    return Just([SubFactionCodex]()).eraseToAnyPublisher()
                }
                return codex.subFactions(edition: editionId, faction: fac.docID)
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
    
    var errorBinding: Binding<Bool> {
        Binding(
            get: { self.errorMessage != nil },
            set: { _ in self.clearError() }
        )
    }
}
