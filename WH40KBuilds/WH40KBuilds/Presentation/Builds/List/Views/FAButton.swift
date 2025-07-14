//
//  FAButton.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct FAButton: View {
    
    @EnvironmentObject var session: SessionStore
    @Binding var showForm: Bool
    
    var body: some View {
        Button { showForm = true } label: {
            Image(systemName: "plus")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.buildBackgroundColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
        }
        .padding(.trailing)
        .padding(.bottom, 14)
        .disabled(!session.isLoggedIn)
    }
}
