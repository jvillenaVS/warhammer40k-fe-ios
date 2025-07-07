//
//  BuildPDFView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 30/6/25.
//

import SwiftUI

struct BuildPDFView: View {
    
    let build: Build
    private let pageSize = CGSize(width: 595, height: 842)
    
    // MARK: – Body
    var body: some View {
        ZStack {
            Color.white
            content
                .padding(40)
        }
        .frame(width: pageSize.width, height: pageSize.height)
    }
    
    // MARK: – Main content
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            
            HStack {
                Image("wh-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 4)
                Spacer()
                Text("Build Report")
                    .font(.inter(.bold, 28))
            }
            
            Divider()
            
            // ── Build info ───────────────────────────────────────────
            Group {
                LabeledItem(label: "Name", value: build.name)
                LabeledItem(label: "Faction", value: build.faction.name)
                LabeledItem(label: "Sub-Faction", value: build.faction.subfaction ?? "-----")
                LabeledItem(label: "Detachment", value: build.detachmentType)
            }
            .font(.inter(.regular, 16))
            
            // ── Points overview ──────────────────────────────────────
            HStack {
                statChip("CP", build.commandPoints)
                statChip("Total Pts", build.totalPoints)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // ── Slots summary ────────────────────────────────────────
            SlotSummaryView(slots: build.slots)
            
            // ── Notes (optional) ─────────────────────────────────────
            if let notes = build.notes, !notes.isEmpty {
                Divider().padding(.vertical, 4)
                Text("Notes")
                    .font(.inter(.semiBold, 18))
                Text(notes)
                    .font(.inter(.regular, 14))
            }
            
            Spacer()
            
            // ── Footer ───────────────────────────────────────────────
            HStack {
                Spacer()
                Text("Generated on \(formattedDate(build.createdAt))")
                    .font(.inter(.light, 10))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: – Helper views
    private func statChip(_ label: String, _ value: Int) -> some View {
        VStack {
            Text("\(value)")
                .font(.inter(.bold, 20))
            Text(label)
                .font(.inter(.regular, 12))
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formattedDate(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }
}

// MARK: – SlotSummaryView ---------------------------------------------------

private struct SlotSummaryView: View {
    let slots: Slots
    
    var body: some View {
        VStack(spacing: 4) {
            slotRow("HQ", slots.hq)
            slotRow("Troops", slots.troops)
            slotRow("Elite", slots.elite)
            slotRow("Fast Attack", slots.fastAttack)
            slotRow("Heavy Support", slots.heavySupport)
            slotRow("Flyers", slots.flyers)
        }
        .font(.inter(.regular, 14))
    }
    
    private func slotRow(_ label: String, _ value: Int) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text("\(value)")
        }
    }
}

// MARK: – LabeledItem (reusable line) --------------------------------------

private struct LabeledItem: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(.inter(.semiBold, 16))
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: – Preview ----------------------------------------------------------
#Preview {
    BuildPDFView(
        build: Build(
            id: "PREV",
            name: "Ultramarines Alpha",
            faction: .init(name: "Ultramarines", subfaction: "2nd Company"),
            detachmentType: "Battalion",
            commandPoints: 6,
            totalPoints: 2000,
            slots: .init(hq: 2, troops: 3, elite: 2,
                         fastAttack: 1, heavySupport: 2, flyers: 0),
            units: [], stratagems: [],
            notes: "This is a sample PDF preview.",
            createdBy: "PreviewUser", createdAt: Date()
        )
    )
}

