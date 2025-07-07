//
//  BuildFormView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct BuildFormView: View {
    
    // ───────── View‑Model & env
    @StateObject private var vm: BuildFormViewModel
    @Environment(\.dismiss)        private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    // ───────── Focus management
    @FocusState private var focus: Field?
    enum Field: Hashable {
        case name
        case cp, pts
        case hq, troops, elite, fast, heavy, flyers
    }
    
    // ───────── Init  (repo y codex inyectados desde la lista)
    init(repository: BuildRepository = FirestoreBuildRepository(),
         codex: CodexRepository     = FirestoreCodexRepository(),
         session: SessionStore) {
        _vm = StateObject(
            wrappedValue: BuildFormViewModel(
                repository: repository,
                codex:      codex,
                session:    session)
        )
    }
    
    // ───────── Body
    var body: some View {
        Form {
            buildInfoSection
            pointsSection
            slotsSection
            saveSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.appBackground)
        .navigationTitle("New Build")
        .onTapGesture { hideKeyboard() }
        
        // Alert global
        .alert("Message",
               isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { _ in vm.clearError() })
        ) { Button("OK", role: .cancel) { } } message: {
            Text(vm.errorMessage ?? "")
        }
        
        // Cierra al guardar
        .onChange(of: vm.saveSuccess) { _, ok in
            if ok { dismiss() }
        }
    }
    
    // MARK: – Build Info
    private var buildInfoSection: some View {
        Section(
            content: {
                
                // Name
                field("Name", text: $vm.name, tag: .name, next: .cp)
                
                // Faction picker
                if vm.factions.isEmpty {
                    ProgressView("Loading factions…")
                } else {
                    Picker("Faction", selection: $vm.selectedFaction) {
                        ForEach(vm.factions) { fac in
                            Text(fac.name)
                                .tag(fac as FactionCodex?)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(.white)
                    .font(.headline)
                }
                
                // Sub‑Faction picker  (dep. de Faction)
                if vm.selectedFaction != nil {
                    if vm.subFactions.isEmpty {
                        HStack {
                            Text("Sub‑Faction")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Text("Not Available")
                                .foregroundStyle(.white)
                        }
                    } else {
                        Picker("Sub‑Faction", selection: $vm.selectedSubFaction) {
                            ForEach(vm.subFactions) { sub in
                                Text(sub.name)
                                    .tag(sub as SubFactionCodex?)
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.white)
                        .font(.headline)
                    }
                }
                
                // Detachment picker  (dep. de Faction)
                if vm.selectedFaction != nil {
                    if vm.detachments.isEmpty {
                        HStack {
                            Text("Detachment")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Text("Not Available")
                                .foregroundStyle(.white)
                        }
                    } else {
                        Picker("Detachment",
                               selection: $vm.selectedDetachment) {
                            ForEach(vm.detachments) { det in
                                Text(det.name)
                                    .tag(det as DetachmentCodex?)
                            }
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(.white)
                        .font(.headline)
                    }
                }
            },
            header: { sectionHeader("Build Info") }
        )
        .listRowBackground(Color.buildFormColor)
    }
    
    // MARK: – Points
    private var pointsSection: some View {
        Section(
            content: {
                numberField("Command Points",
                            text: $vm.commandPoints,
                            tag: .cp, next: .pts)
                    .validationMessage(vm.formState.errors[.cp])
                
                numberField("Total Points",
                            text: $vm.totalPoints,
                            tag: .pts, next: .hq)
                    .validationMessage(vm.formState.errors[.points])
            },
            header: { sectionHeader("Points") }
        )
        .listRowBackground(Color.buildFormColor)
    }
    
    // MARK: – Slots
    private var slotsSection: some View {
        Section(
            content: {
                slot("HQ",     text: $vm.hq,     focus: .hq,     field: .hq,     next: .troops)
                slot("Troops", text: $vm.troops, focus: .troops, field: .troops, next: .elite)
                slot("Elite",  text: $vm.elite,  focus: .elite,  field: .elite,  next: .fast)
                slot("Fast",   text: $vm.fast,   focus: .fast,   field: .fast,   next: .heavy)
                slot("Heavy",  text: $vm.heavy,  focus: .heavy,  field: .heavy,  next: .flyers)
                slot("Flyers", text: $vm.flyers, focus: .flyers, field: .flyers, next: nil)
            },
            header: { sectionHeader("Slots") }
        )
        .listRowBackground(Color.buildFormColor)
    }
    
    // MARK: – Save
    private var saveSection: some View {
        Section(content: {
            Button {
                hideKeyboard()
                vm.saveBuild()
            } label: {
                if vm.isSaving { ProgressView() }
                else { Text("Save Build")
                        .frame(maxWidth: .infinity) }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.formState.isValid || vm.isSaving)
        })
        .listRowBackground(Color.clear)
    }
    
    // MARK: – Field helpers
    private func field(_ title: LocalizedStringKey,
                       text: Binding<String>,
                       tag: Field, next: Field?) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: tag)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit { focus = next }
    }
    
    private func numberField(_ title: LocalizedStringKey,
                             text: Binding<String>,
                             tag: Field, next: Field?) -> some View {
        TextField(title, text: text)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: tag)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit { focus = next }
    }
    
    private func slot(_ title: LocalizedStringKey,
                      text: Binding<String>,
                      focus: Field,
                      field: BuildFormState.Field,
                      next: Field?) -> some View {
        numberField(title, text: text, tag: focus, next: next)
            .validationMessage(vm.formState.errors[field])
    }
    
    // MARK: – Decoration helpers
    private func sectionHeader(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .textCase(nil)
    }
}

// ───────── Validation overlay helper
private extension View {
    @ViewBuilder
    func validationMessage(_ msg: String?) -> some View {
        if let msg {
            VStack(alignment: .leading, spacing: 2) {
                self
                Text(msg)
                    .font(.caption2)
                    .foregroundColor(.red)
            }
        } else {
            self
        }
    }
}
