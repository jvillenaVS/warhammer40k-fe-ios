//
//  DeleteView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 3/7/25.
//

import SwiftUI

struct DeleteView: View {
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 20) {
                Text("Delete Build?")
                    .font(.headline)

                Text("Are you sure you want to delete this build?")
                    .font(.subheadline)
                    .foregroundStyle(.black.opacity(0.8))
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button("Cancel", role: .cancel, action: onCancel)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.black)

                    Button("Delete", role: .destructive, action: onDelete)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color.red, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .shadow(radius: 16, y: 6)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring, value: 0)
    }
}

