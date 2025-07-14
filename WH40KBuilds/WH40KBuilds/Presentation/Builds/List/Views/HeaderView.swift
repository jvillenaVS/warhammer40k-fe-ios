//
//  HeaderView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("wh-list-icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 30, height: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title.bold())
                    .foregroundColor(.buildTitleColor)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.buildSubTitleColor)
            }
        }
    }
}
