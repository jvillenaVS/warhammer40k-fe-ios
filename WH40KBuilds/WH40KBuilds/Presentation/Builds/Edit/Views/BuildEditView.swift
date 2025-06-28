//
//  BuildEditView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildEditView: View {
    @StateObject var vm: BuildEditViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General")) {
                    TextField("Name", text: $vm.name)
                    TextField("Detachment", text: $vm.detachmentType)
                }
                
                Section(header: Text("Points")) {
                    TextField("Command Points", text: $vm.commandPoints)
                        .keyboardType(.numberPad)
                    TextField("Total Points", text: $vm.totalPoints)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $vm.notes)
                        .frame(height: 120)
                }
            }
            .navigationTitle("Edit Build")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { vm.save() }
                        .disabled(vm.name.isEmpty)
                }
            }
            .alert("Error", isPresented: $vm.showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage ?? "Unknown Error")
            }
            .onChange(of: vm.dismiss) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }
}
