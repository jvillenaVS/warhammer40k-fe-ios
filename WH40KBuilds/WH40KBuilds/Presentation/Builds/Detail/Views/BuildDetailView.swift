//
//  BuildDetailView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildDetailView: View {
    
    // Binding: la vista madre (lista) pasa $build
    @Binding var build: Build
    
    // Dependencias
    let repository: BuildRepository
    @EnvironmentObject private var session: SessionStore
    
    // Navegación al editor
    @State private var showEdit = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Encabezado
                Text(build.name)
                    .font(.largeTitle).bold()
                
                // Faction / Detachment
                HStack {
                    VStack(alignment: .leading) {
                        Text("Faction:")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(build.faction.name)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Detachment:")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(build.detachmentType)
                    }
                }
                
                // Puntos
                HStack {
                    statChip("CP", value: build.commandPoints)
                    statChip("Pts", value: build.totalPoints)
                }
                
                Divider()
                
                // Slots (solo resumen)
                slotRow("HQ", build.slots.hq)
                slotRow("Troops", build.slots.troops)
                slotRow("Elite", build.slots.elite)
                slotRow("Fast Attack", build.slots.fastAttack)
                slotRow("Heavy", build.slots.heavySupport)
                slotRow("Flyers", build.slots.flyers)
                
                // Notas
                if let notes = build.notes, !notes.isEmpty {
                    Divider()
                    Text("Notes")
                        .font(.headline)
                    Text(notes)
                }
            }
            .padding()
        }
        .navigationTitle("Build Detail")
        .toolbar {
            // Botón Edit
            Button("Edit") { showEdit = true }
        }
        // Push a pantalla completa
        .navigationDestination(isPresented: $showEdit) {
            BuildEditView(
                build: $build,
                repository: repository,
                session: session
            )
        }
    }
    
    // MARK: - Helper views
    private func statChip(_ label: String, value: Int) -> some View {
        VStack {
            Text("\(value)")
                .font(.title2).bold()
            Text(label).font(.caption)
        }
        .padding(8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func slotRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
        }
    }
}

// MARK: - Preview
#Preview {
    let session = SessionStore(service: MockAuthService())
    NavigationStack {
        BuildDetailView(
            build: .constant(
                Build(id: "1",
                      name: "Sample",
                      faction: .init(name: "Ultramarines", subfaction: nil),
                      detachmentType: "Battalion",
                      commandPoints: 6,
                      totalPoints: 2000,
                      slots: .init(hq: 2, troops: 3, elite: 2,
                                   fastAttack: 1, heavySupport: 2, flyers: 0),
                      units: [], stratagems: [],
                      notes: "Preview notes",
                      createdBy: "uid", createdAt: .now)
            ),
            repository: MockBuildRepository()
        )
    }
    .environmentObject(session)
}

