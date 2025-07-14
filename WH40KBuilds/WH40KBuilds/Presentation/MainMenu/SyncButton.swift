//
//  SyncButton.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct SyncButton: View {
    
    @Binding var showSyncMessage: Bool
    @Binding var syncMessage: String
    @Binding var isSyncing: Bool

    var body: some View {
        Button(action: onSyncTapped) {
            HStack(spacing: 8) {
                Image(systemName: isSyncing
                      ? "arrow.triangle.2.circlepath.circle.fill"
                      : "arrow.triangle.2.circlepath")
                    .imageScale(.large)
                    .rotationEffect(.degrees(isSyncing ? 360 : 0))
                    .animation(
                        isSyncing
                        ? .easeInOut(duration: 1).repeatForever(autoreverses: false)
                        : .default,
                        value: isSyncing
                    )

                Text(isSyncing ? "Syncing…" : "Sync Codex Data")
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 28)
        }
        .buttonStyle(NeumorphicStyle())
        .disabled(isSyncing)
    }

    private func onSyncTapped() {
        isSyncing = true
        Task {
            do {
                let downloaded = try await CodexSyncManager.shared.syncAllCodexData()
                showSyncFeedback(
                    message: """
                    ✅ Sync done!
                    \(Date().toFormattedString())
                    Editions: \(downloaded.joined(separator: ", "))
                    """
                )
            } catch {
                showSyncFeedback(
                    message: """
                    ❌ Sync failed!
                    \(Date().toFormattedString())
                    """
                )
            }
            isSyncing = false
        }
    }
    
    private func showSyncFeedback(message: String) {
        syncMessage = message
        showSyncMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            showSyncMessage = false
        }
    }

}
