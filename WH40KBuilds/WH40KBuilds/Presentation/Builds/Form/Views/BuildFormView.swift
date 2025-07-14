//
//  BuildFormView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct BuildFormView: View {
    
    @StateObject private var vm: BuildFormViewModel
    @Environment(\.dismiss)        private var dismiss
    @EnvironmentObject private var session: SessionStore
    @FocusState private var focus: Field?
    @State private var showingAlert = false
    
    init(repository: BuildRepository = FirestoreBuildRepository(),
         codex: CodexRepository     = FirestoreCodexRepository()) {
        _vm = StateObject(wrappedValue:
                            BuildFormViewModel(repository: repository,
                                               codex:      codex))
    }
    
    var body: some View {
        formCore
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("New Build")
            .onTapGesture { hideKeyboard() }
            .alert(isPresented: vm.errorBinding, content: errorAlert)
            .onChange(of: vm.saveSuccess) { _, ok in
                if ok { dismiss() }
            }
            .onAppear {
                if vm.session == nil { vm.attachSession(session) }
            }
    }
    
    private var formCore: some View {
        Form {
            buildInfoSection
            pointsSection
            slotsSection
            saveSection
        }
    }
    
    private func errorAlert() -> Alert {
        Alert(title: Text("Message"),
              message: Text(vm.errorMessage ?? ""),
              dismissButton: .default(Text("OK")) {
            vm.clearError()
        })
    }
    
    private var buildInfoSection: some View {
        Section(
            content: {
                
                field("Name", text: $vm.name, tag: .name, next: .cp)
                
                if vm.editions.isEmpty {
                    ProgressView("Loading editions…")
                } else {
                    Picker("Edition", selection: $vm.selectedEdition) {
                        ForEach(vm.editions) { edition in
                            Text(edition.name)
                                .tag(edition as EditionCodex?)
                        }
                    }
                    .pickerStyle()
                }

                if vm.factions.isEmpty {
                    HStack {
                        Text("action")
                            .foregroundColor(.white)
                            .font(.headline)
                        Spacer()
                        Text("Not Available")
                            .foregroundStyle(.white)
                    }
                } else {
                    Picker("Faction", selection: $vm.selectedFaction) {
                        ForEach(vm.factions) { fac in
                            Text(fac.name)
                                .tag(fac as FactionCodex?)
                        }
                    }
                    .pickerStyle()
                }
                
                if vm.selectedFaction != nil {
                    if vm.subFactions.isEmpty {
                        HStack {
                            Text("Sub‑Faction")
                                .foregroundColor(.white)
                                .font(.inter(.medium, 14))
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
                        .pickerStyle()
                    }
                }
            
                if vm.selectedFaction != nil {
                    if vm.detachments.isEmpty {
                        HStack {
                            Text("Detachment")
                                .foregroundColor(.white)
                                .font(.inter(.medium, 14))
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
                        .pickerStyle()
                    }
                }
            },
            header: { sectionHeader("Build Info") }
        )
        .listRowBackground(Color.buildFormColor)
    }
    
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
    
    private func sectionHeader(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.white)
            .textCase(nil)
    }
}
