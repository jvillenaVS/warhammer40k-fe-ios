//
//  BuildDetailView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import SwiftUI
import PDFKit

struct BuildDetailView: View {
    
    @EnvironmentObject private var session: SessionStore
    @Binding var build: Build
    let repository: BuildRepository
    
    // MARK: - Navigation & Share
    @State private var showEdit   = false
    @State private var pdfURL: URL?
    @State private var showShare  = false
    @State private var exportError: String?
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerCard
                factionSection
                slotsCard
                if let notes = build.notes, !notes.isEmpty {
                    notesCard(text: notes)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .navigationTitle("Build Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { topToolbar }
        .navigationDestination(isPresented: $showEdit) { buildEdit }
        .sheet(isPresented: $showShare) { shareSheet }
        .alert("Export error",
               isPresented: Binding(get: { exportError != nil },
                                    set: { _ in exportError = nil })) {
            Button("OK", role: .cancel) { }
        } message: { Text(exportError ?? "") }
        .background(Color.appBg)
    }
}

// MARK: - UI Components
private extension BuildDetailView {
    
    // ───────── Header ─────────
    var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(build.name)
                .font(.inter(.bold, 34))
                .lineLimit(2)
                .foregroundStyle(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                statChip("CP", build.commandPoints, color: .buildTitle)
                statChip("Pts", build.totalPoints, color: .buildTint)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.buildForm)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4, y: 2)
    }
    
    // ───────── Faction / Sub‑Faction / Detachment ─────────
    var factionSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                infoCard(title: "Faction",
                         value: build.faction.name,
                         icon: validSymbol("lag.fill"))
                
                infoCard(title: "Detachment",
                         value: build.detachmentType,
                         icon: validSymbol("puzzlepiece.fill"))
            }
            
            if let sub = build.faction.subfaction,
               !sub.trimmingCharacters(in: .whitespaces).isEmpty {
                infoCard(title: "Sub‑Faction",
                         value: sub,
                         icon: validSymbol("shield.lefthalf.fill"))
            }
        }
    }
    
    // ───────── Slots card ─────────
    var slotsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Force Slots").font(.headline)
                .foregroundColor(.white.opacity(0.8))
            ForEach(slotTuples, id: \.0) { label, count, icon in
                HStack {
                    Label(label, systemImage: icon)
                        .foregroundColor(.white.opacity(0.8))
                        .tint(.white.opacity(0.8))
                    Spacer()
                    Text("\(count)").bold()
                        .foregroundColor(.white)
                    
                }
                .font(.inter(.regular, 16))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.buildForm)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // ───────── Notes card ─────────
    func notesCard(text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").font(.headline)
            Text(text).font(.inter(.light, 15))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // ───────── Helper: info card ─────────
    func infoCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.white)
            Text(value).font(.inter(.medium, 16))
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.buildForm)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    // ───────── Helper: stat chip ─────────
    func statChip(_ label: String, _ value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)").font(.title3).bold()
                .foregroundColor(.white)
            Text(label).font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(10)
        .frame(width: 80)
        .background(color.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func validSymbol(_ primary: String, fallback: String = "flag.fill") -> String {
        UIImage(systemName: primary) == nil ? fallback : primary
    }
    
    func getRepository() -> BuildRepository {
        return repository
    }
    
}

// MARK: - Slots meta‑data
private extension BuildDetailView {
    var slotTuples: [(String, Int, String)] {
        [
            ("HQ",          build.slots.hq,           "person.2.square.stack"),
            ("Troops",      build.slots.troops,       "person.3.fill"),
            ("Elite",       build.slots.elite,        "staroflife.circle"),
            ("Fast Attack", build.slots.fastAttack,   "bolt.fill"),
            ("Heavy",       build.slots.heavySupport, "shield.lefthalf.filled"),
            ("Flyers",      build.slots.flyers,       "airplane")
        ]
    }
}

// MARK: - Toolbar & Navigation
private extension BuildDetailView {
    var topToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button { showEdit = true }  label: { Image(systemName: "pencil") }
            Button { Task { await exportPDF() } } label: { Image(systemName: "square.and.arrow.up") }
        }
    }
    
    var buildEdit: some View {
        BuildEditView(build: $build,
                      repository: repository,
                      session: session)
    }
    
    @ViewBuilder
    var shareSheet: some View {
        if let url = pdfURL {
            SharePDFView(url: url)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Export to PDF
private extension BuildDetailView {
    @MainActor
    func exportPDF() async {
        do {
            let url = try await SwiftUIPDFExporter().export(build: build)
            pdfURL = url
            showShare = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}
