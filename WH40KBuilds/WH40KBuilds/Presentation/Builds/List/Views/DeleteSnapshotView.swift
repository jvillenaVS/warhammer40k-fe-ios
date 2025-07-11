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
                Text("Delete Build")
                    .font(.inter(.bold, 18))
                    .foregroundStyle(.white)

                Text("Are you sure you want to delete this build?")
                    .font(.inter(.regular, 14))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Button("Cancel", role: .cancel, action: onCancel)
                        .font(.inter(.medium, 13))
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(Color(.systemGray5), in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.black)

                    Button("Delete", role: .destructive, action: onDelete)
                        .font(.inter(.medium, 13))
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(.clear, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.redCancel)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.redCancel, lineWidth: 1.0)
                        )
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
