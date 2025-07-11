//
//  SecurityActionsSection.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 8/7/25.
//

import SwiftUI

struct SecurityActionsSection: View {
    var onChangePassword: () -> Void
    var onLogout: () -> Void

    private let rowHeight: CGFloat = 44
    private let cornerRadius: CGFloat = 12
    private let horizontalPadding: CGFloat = 28
    private let buttonSpacing: CGFloat = 36
    private let buttonHeight: CGFloat = 48

    var body: some View {
        HStack(spacing: buttonSpacing) {
        
            Button(action: onChangePassword) {
                Text("Change Password")
                    .font(.inter(.medium, 14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.buildTint)
                    .clipShape(RoundedRectangle(cornerRadius: buttonHeight/2, style: .continuous))
            }

            Button(action: onLogout) {
                Text("Logout")
                    .font(.inter(.medium, 14))
                    .foregroundStyle(.redCancel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 8)
                    .background(.clear)
                    .clipShape(RoundedRectangle(cornerRadius: buttonHeight/2, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: buttonHeight/2)
                            .stroke(.redCancel, lineWidth: 1.0)
                    )
            }
        }
        .frame(height: buttonHeight)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 8)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
