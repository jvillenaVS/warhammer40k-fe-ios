//
//  EmptyStateView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct EmptyStateView: View {
    let isLoggedIn: Bool
    var body: some View {
        ContentUnavailableView(
            isLoggedIn ? "No builds yet" : "Login required",
            systemImage: "tray",
            description: Text(
                isLoggedIn
                ? "Tap + to create your first build."
                : "Please log in to see or create builds.")
        )
        .foregroundColor(.white)
    }
}
