//
//  BuildFormView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct BuildFormView: View {
    @StateObject private var vm: BuildFormViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    
    @FocusState private var focus: Field?
    enum Field: Hashable {
        case name, faction, subfaction, detachment
        case cp, points
        case hq, troops, elite, fast, heavy, flyers
    }
    
    init(repository: BuildRepository = FirestoreBuildRepository(),
         session: SessionStore) {
        _vm = StateObject(wrappedValue: BuildFormViewModel(
            repository: repository,
            session: session
        ))
    }
    
    var body: some View {
        
        Form {
            // ───────────── Build Info ─────────────
            Section {
                field("Name", text: $vm.name, tag: .name, next: .faction)
                field("Faction", text: $vm.faction, tag: .faction, next: .subfaction)
                field("Sub‑Faction", text: $vm.subfaction, tag: .subfaction, next: .detachment)
                field("Detachment Type", text: $vm.detachmentType, tag: .detachment, next: .cp)
            } header: {
                Text("Build Info")
                    .font(.headline)
                    .foregroundColor(.white)
                    .textCase(nil)
            }
            
            // ───────────── Points ─────────────
            Section {
                numberField("Command Points", text: $vm.commandPoints, tag: .cp, next: .points)
                numberField("Total Points", text: $vm.totalPoints, tag: .points, next: .hq)
            } header: {
                Text("Points")
                    .font(.headline)
                    .foregroundColor(.white)
                    .textCase(nil)
            }
          
            // ───────────── Slots ─────────────
            Section {
                numberField("HQ",          text: $vm.hq,     tag: .hq,     next: .troops)
                numberField("Troops",      text: $vm.troops, tag: .troops, next: .elite)
                numberField("Elite",       text: $vm.elite,  tag: .elite,  next: .fast)
                numberField("Fast Attack", text: $vm.fast,   tag: .fast,   next: .heavy)
                numberField("Heavy Supp.", text: $vm.heavy,  tag: .heavy,  next: .flyers)
                numberField("Flyers",      text: $vm.flyers, tag: .flyers, next: nil)
            } header: {
                Text("Slots")
                    .font(.headline)
                    .foregroundColor(.white)
                    .textCase(nil)
            }
            
            // ───────────── Save ─────────────
            Section {
                Button(action: save) {
                    if vm.isSaving { ProgressView() }
                    else { Text("Save Build").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
        }
        .navigationTitle("New Build")
        .onTapGesture { hideKeyboard() }
        .scrollContentBackground(.hidden)
        .background(Color.appBg)
        
        // Alert de error
        .alert("Message",
               isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { _ in vm.clearError() })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        // Cierra al guardar
        .onChange(of: vm.saveSuccess) { _, new in
            if new { dismiss() }
        }
        
    }
    
    // MARK: – Helpers UI
    private func field(_ title: LocalizedStringKey,
                       text: Binding<String>,
                       tag: Field,
                       next: Field?) -> some View {
        TextField(title, text: text)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: tag)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit { focus = next }
    }
    
    private func numberField(_ title: LocalizedStringKey,
                             text: Binding<String>,
                             tag: Field,
                             next: Field?) -> some View {
        TextField(title, text: text)
            .keyboardType(.numberPad)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: tag)
            .submitLabel(next == nil ? .done : .next)
            .onSubmit { focus = next }
    }
    
    private func save() {
        hideKeyboard()
        vm.saveBuild()
    }
}

