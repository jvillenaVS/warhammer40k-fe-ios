//
//  BuildRowView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct BuildRowView: View {
    let build: Build
    let onView: () -> Void
    let onTrash: () -> Void

    private let imgSize = CGSize(width: 100, height: 120)

    var body: some View {
        HStack(spacing: 16) {

            let imgName = "faction_\(build.faction.name.lowercased())"
            let uiImage = UIImage(named: imgName) ?? UIImage(named: "wh-logo")!

            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: imgSize.width, height: imgSize.height)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(build.name)
                        .font(.headline)
                        .foregroundColor(.buildTitleColor)
                        .lineLimit(2)
                    Text(build.faction.name)
                        .font(.subheadline)
                        .foregroundColor(.buildSubTitleColor)
                }

                Spacer()

                HStack(spacing: 12) {
                    RectButton(title: "View",
                               bg: .buildBackgroundColor,
                               fg: .white,
                               action: onView)
                    RectButton(title: "Trash",
                               bg: .clear,
                               fg: .buildTintColor,
                               action: onTrash)
                }
            }
            .frame(height: imgSize.height)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.white.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
