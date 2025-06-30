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
    
    // Focus management
    @FocusState private var focusedField: Field?
    enum Field {
        case name, faction, subfaction, detachment, commandPoints, totalPoints
    }
    
    // MARK: – Init
    init(repository: BuildRepository = FirestoreBuildRepository(),
         session: SessionStore) {
        _vm = StateObject(wrappedValue: BuildFormViewModel(
            repository: repository,
            session: session
        ))
    }
    
    // MARK: – Body
    var body: some View {
        Form {
            Section("Build Info") {
                TextField("Name", text: $vm.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .faction }
                
                TextField("Faction", text: $vm.faction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .faction)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .subfaction }
                
                TextField("Subfaction", text: $vm.subfaction)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .subfaction)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .detachment }
                
                TextField("Detachment Type", text: $vm.detachmentType)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .detachment)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .commandPoints }
            }
            
            Section("Points") {
                TextField("Command Points", text: $vm.commandPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .commandPoints)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .totalPoints }
                
                TextField("Total Points", text: $vm.totalPoints)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($focusedField, equals: .totalPoints)
                    .submitLabel(.continue)
                    .onSubmit { vm.saveBuild() }
            }
            
            Section {
                Button {
                    vm.saveBuild()
                } label: {
                    if vm.isSaving { ProgressView() }
                    else { Text("Save Build").frame(maxWidth: .infinity) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
        }
        .navigationTitle("New Build")
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }
        .alert("Message",
               isPresented: Binding(
                   get: { vm.errorMessage != nil },
                   set: { _ in vm.clearError() })
        ) { Button("OK", role: .cancel) { } } message: {
            Text(vm.errorMessage ?? "")
        }
        
        .onChange(of: vm.saveSuccess) { _, newValue in
            if newValue { dismiss() }
        }
    }
}

// MARK: – Preview
#Preview {
    let session = SessionStore(service: MockAuthService())
    BuildFormView(
        repository: MockBuildRepository(),
        session: session
    )
    .environmentObject(session)
}
