//
//  BuildEditView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildEditView: View {
    
    // Binding al objeto de origen
    @Binding var build: Build
    
    // ViewModel
    @StateObject private var vm: BuildEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Focus control
    @FocusState private var focused: Field?
    enum Field {
        case name, faction, subfaction, detachment, cp, tp
    }
    
    // MARK: - Init
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
    
    // MARK: - Body
    var body: some View {
        Form {
            Section("Build Info") {
                TextField("Name", text: $vm.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focused = .faction }
                
                TextField("Faction", text: $vm.faction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .faction)
                    .submitLabel(.next)
                    .onSubmit { focused = .subfaction }
                
                TextField("Subfaction", text: $vm.subfaction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .subfaction)
                    .submitLabel(.next)
                    .onSubmit { focused = .detachment }
                
                TextField("Detachment", text: $vm.detachmentType)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .detachment)
                    .submitLabel(.next)
                    .onSubmit { focused = .cp }
            }
            
            Section("Points") {
                TextField("Command Points", text: $vm.commandPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .cp)
                    .submitLabel(.next)
                    .onSubmit { focused = .tp }
                
                TextField("Total Points", text: $vm.totalPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused, equals: .tp)
                    .submitLabel(.continue)
                    .onSubmit { vm.save() }
            }
            Section {
                Button {
                    vm.save()
                } label: {
                    if vm.isSaving { ProgressView() }
                    else { Text("Save").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
            
        }
        .navigationTitle("Edit Build")
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }   // Oculta teclado
        .alert("Error",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { _ in vm.clearError() })
        ) { Button("OK", role: .cancel) { } } message: {
            Text(vm.errorMessage ?? "")
        }
        // Actualiza binding y cierra
        .onChange(of: vm.saveSuccess) { _, newValue in
            if newValue, let edited = vm.updatedBuild {
                build = edited
                dismiss()
            }
        }
    }
}
