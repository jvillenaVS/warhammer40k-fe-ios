//
//  BuildFormView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI

struct BuildFormView: View {
    @StateObject var vm: BuildFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            // MARK: ‑ Build Info
            Section(header: Text("Build Info")) {
                TextField("Name", text: $vm.name)
                fieldError(.name)
                
                TextField("Faction", text: $vm.faction)
                fieldError(.faction)
                
                TextField("Subfaction", text: $vm.subfaction)
                TextField("Detachment", text: $vm.detachmentType)
            }
            
            // MARK: ‑ Points
            Section(header: Text("Points")) {
                TextField("Command Points", text: $vm.commandPoints)
                    .keyboardType(.numberPad)
                fieldError(.commandPoints)
                
                TextField("Total Points", text: $vm.totalPoints)
                    .keyboardType(.numberPad)
                fieldError(.totalPoints)
            }
            
            // MARK: ‑ Save Button
            Section {
                Button(action: vm.saveBuild) {
                    if vm.isSaving {
                        ProgressView()
                    } else {
                        Text("Save Build")
                    }
                }
                .disabled(!vm.formState.isValid || vm.isSaving)
            }
        }
        .navigationTitle("New Build")
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil })
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .onChange(of: vm.saveSuccess) { _, newValue in
            if newValue { dismiss() }
        }
    }
    
    // Helper that shows inline error message
    @ViewBuilder
    private func fieldError(_ field: BuildFormState.Field) -> some View {
        if let msg = vm.formState.errors[field] {
            Text(msg)
                .font(.caption)
                .foregroundStyle(.red)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BuildFormView(
            vm: BuildFormViewModel(
                repository: MockBuildRepository()
            )
        )
    }
}




    
