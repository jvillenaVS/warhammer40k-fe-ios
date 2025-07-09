//
//  AccountInfoSection.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import SwiftUI

struct AccountInfoSection: View {
   
    @Binding var username: String
    @Binding var email: String

    var onEditTapped: () -> Void

    // MARK: - Constantes de estilo
    private let rowHeight: CGFloat = 40
    private let cornerRadius: CGFloat = 12
    private let sectionIcon = "lock.circle"

    var body: some View {
        VStack(spacing: 0) {
          
            HStack {
                Image(systemName: sectionIcon)
                    .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.buildTitle)

                Text("Account Info")
                    .font(.inter(.bold, 16))
                    .foregroundColor(.buildTitle)

                Spacer()

                Button(action: onEditTapped) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .frame(height: rowHeight)

            Divider()

            fieldRow(label: "Username", value: "@" + username)
            Divider()
            fieldRow(label: "Email", value: email)
        }
        .background(Color.buildForm)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .padding(.horizontal, 20)
    }

    // MARK: - Helper
    @ViewBuilder
    private func fieldRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.inter(.medium, 14))
                .foregroundColor(.white)
                .lineLimit(1)

            Spacer(minLength: 16)

            Text(value.isEmpty ? "—" : value)
                .font(.inter(.regular, 14))
                .foregroundColor(value.isEmpty ? .secondary : .white)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.horizontal)
        .frame(height: rowHeight)
    }
}
