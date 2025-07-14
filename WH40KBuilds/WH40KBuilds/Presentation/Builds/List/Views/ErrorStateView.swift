//
//  ErrorStateView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct ErrorStateView: View {
    let error: String
    var body: some View {
        VStack {
            Text("Error loading builds:")
                .font(.headline)
            Text(error)
                .multilineTextAlignment(.center)
        }
        .foregroundColor(.white)
        .padding()
    }
}
