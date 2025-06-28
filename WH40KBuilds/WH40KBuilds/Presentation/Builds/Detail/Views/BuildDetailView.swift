//
//  BuildDetailView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI

struct BuildDetailView: View {
    
    // MARK: - ViewModel
    @StateObject var viewModel: BuildDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Notas editables localmente antes de presionar “Save Notes”
    @State private var draftNotes: String = ""
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // ===== Header =====
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.build.name)
                        .font(.largeTitle).bold()
                    
                    Text("\(viewModel.build.faction.name)\(viewModel.build.faction.subfaction.map { " - \($0)" } ?? "")")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 24) {
                    StatCard(title: "CP", value: "\(viewModel.build.commandPoints)")
                    StatCard(title: "Points", value: "\(viewModel.build.totalPoints)")
                    StatCard(title: "Detachment", value: viewModel.build.detachmentType)
                }
                
                Divider()
                
                // ===== Slots =====
                VStack(alignment: .leading, spacing: 6) {
                    Text("Slots").font(.headline)
                    slotRows
                }
                
                Divider()
                
                // ===== Units =====
                VStack(alignment: .leading, spacing: 8) {
                    Text("Units").font(.headline)
                    
                    ForEach(viewModel.build.units) { unit in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(unit.name).bold()
                            Text("Type: \(unit.type)").font(.caption)
                            Text("Cost: \(unit.unitTotalCost) pts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(.gray.opacity(0.1)))
                    }
                }
                
                // ===== Stratagems =====
                if !viewModel.build.stratagems.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stratagems").font(.headline)
                        ForEach(viewModel.build.stratagems) { stratagem in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stratagem.name).bold()
                                Text("Cost: \(stratagem.costCP) CP")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(stratagem.description)
                            }
                            .padding(6)
                            .background(RoundedRectangle(cornerRadius: 8)
                                            .fill(.gray.opacity(0.08)))
                        }
                    }
                }
                
                // ===== Notes =====
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes").font(.headline)
                    TextEditor(text: $draftNotes)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(.gray.opacity(0.3)))
                    
                    Button("Save Notes") {
                        viewModel.build.notes = draftNotes
                        viewModel.saveChanges()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
        .navigationTitle("Build Detail")
        .onAppear { draftNotes = viewModel.build.notes ?? "" }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    BuildEditView(
                        vm: BuildEditViewModel(
                            build: viewModel.build,
                            repo: FirestoreBuildRepository()
                        )
                    )
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var slotRows: some View {
        Group {
            SlotRow(label: "HQ",          value: viewModel.build.slots.hq)
            SlotRow(label: "Troops",      value: viewModel.build.slots.troops)
            SlotRow(label: "Elite",       value: viewModel.build.slots.elite)
            SlotRow(label: "Fast Attack", value: viewModel.build.slots.fastAttack)
            SlotRow(label: "Heavy",       value: viewModel.build.slots.heavySupport)
            SlotRow(label: "Flyers",      value: viewModel.build.slots.flyers)
        }
    }
}

// MARK: - Helper Views

private struct StatCard: View {
    let title: String
    let value: String
    var body: some View {
        VStack {
            Text(value).font(.title2).bold()
            Text(title).font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SlotRow: View {
    let label: String
    let value: Int
    var body: some View {
        HStack {
            Text(label).frame(width: 110, alignment: .leading)
            Spacer()
            Text("\(value)")
        }
    }
}

// MARK: - Preview
#Preview {
    let mockBuild = Build(
        id: "1",
        name: "Preview Build",
        faction: .init(name: "Space Wolves", subfaction: "Fifth Company"),
        detachmentType: "Patrol",
        commandPoints: 3,
        totalPoints: 1000,
        slots: .init(hq: 1, troops: 2, elite: 1, fastAttack: 0, heavySupport: 0, flyers: 0),
        units: [],
        stratagems: [],
        notes: "Preview notes",
        createdBy: "Preview",
        createdAt: .now
    )
    return NavigationStack {
        BuildDetailView(
            viewModel: BuildDetailViewModel(
                build: mockBuild,
                repo: MockBuildRepository()
            )
        )
    }
}

