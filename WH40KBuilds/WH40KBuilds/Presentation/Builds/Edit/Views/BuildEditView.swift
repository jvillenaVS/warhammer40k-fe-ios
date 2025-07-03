//
//  BuildEditView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildEditView: View {
    
    @Binding var build: Build
    @StateObject private var vm: BuildEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focus: Field?
    enum Field: Hashable {
        case name, faction, subfaction, detachment
        case cp, points
        case hq, troops, elite, fast, heavy, flyers
    }
    
    init(build: Binding<Build>,
         repository: BuildRepository,
         session: SessionStore) {
        self._build = build
        _vm = StateObject(wrappedValue:
            BuildEditViewModel(build: build.wrappedValue,
                               repository: repository,
                               session: session)
        )
    }
    
    var body: some View {
        Form {
            // ───────── Build Info ─────────
            Section {
                field("Name",        text: $vm.name,           tag: .name,       next: .faction)
                field("Faction",     text: $vm.faction,        tag: .faction,    next: .subfaction)
                field("Sub‑Faction", text: $vm.subfaction,     tag: .subfaction, next: .detachment)
                field("Detachment",  text: $vm.detachmentType, tag: .detachment, next: .cp)
            } header: {
                Text("Build Info")
                    .font(.headline)
                    .foregroundColor(.white)
                    .textCase(nil)
            }
            
            // ───────── Points ─────────
            Section {
                numField("Command Points", text: $vm.commandPoints, tag: .cp,     next: .points)
                numField("Total Points",   text: $vm.totalPoints,   tag: .points, next: .hq)
            } header: {
                Text("Points")
                    .font(.headline)
                    .foregroundColor(.white)
                    .textCase(nil)
            }
            
            // ───────── Slots ─────────
            Section {
                numField("HQ",          text: $vm.hq,     tag: .hq,     next: .troops)
                numField("Troops",      text: $vm.troops, tag: .troops, next: .elite)
                numField("Elite",       text: $vm.elite,  tag: .elite,  next: .fast)
                numField("Fast Attack", text: $vm.fast,   tag: .fast,   next: .heavy)
                numField("Heavy Supp.", text: $vm.heavy,  tag: .heavy,  next: .flyers)
                numField("Flyers",      text: $vm.flyers, tag: .flyers, next: nil)
            } header: {
                Text("Slots")
                    .font(.headline)
                    .foregroundColor(.white)
                    .textCase(nil)
            }
            
            // ───────── Save ─────────
            Section {
                Button(action: edit) {
                    if vm.isSaving { ProgressView() }
                    else { Text("Save Changes").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
        }
        .navigationTitle("Edit Build")
        .onTapGesture { hideKeyboard()}
        .scrollContentBackground(.hidden)
        .background(Color.appBg)
        
        // Alert
        .alert("Error",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { _ in vm.clearError() })
        ) { Button("OK", role: .cancel) { } } message: {
            Text(vm.errorMessage ?? "")
        }
        // Cierra y actualiza binding
        .onChange(of: vm.saveSuccess) { _, new in
            if new, let edited = vm.updatedBuild {
                build = edited
                dismiss()
            }
        }
    }
    
    // MARK: – Helpers
    private func field(_ title: LocalizedStringKey,
                       text: Binding<String>,
                       tag: Field, next: Field?) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: tag)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit { focus = next }
    }
    
    private func numField(_ title: LocalizedStringKey,
                          text: Binding<String>,
                          tag: Field, next: Field?) -> some View {
        TextField(title, text: text)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: tag)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit { focus = next }
    }
    
    private func edit() {
        hideKeyboard()
        vm.editBuild()
    }
}
