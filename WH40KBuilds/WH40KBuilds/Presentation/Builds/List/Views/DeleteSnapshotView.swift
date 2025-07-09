//
//  DeleteSnapshotView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 9/7/25.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct DeleteSnapshotView: View {
    let snapshot: UIImage
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Image(uiImage: snapshot)
                .resizable()
                .scaledToFill()
                .blur(radius: 8)
                .ignoresSafeArea()

            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Delete Build?")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Are you sure you want to delete this build?")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button("Cancel", role: .cancel, action: onCancel)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.black)

                    Button("Delete", role: .destructive, action: onDelete)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.redCancel, in: RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(.dialogGradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(radius: 16, y: 6)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

extension ShapeStyle where Self == LinearGradient {
    static var dialogGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.dialogBackgroundColor.opacity(0.85),
                Color.dialogBottomColor.opacity(0.85)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
