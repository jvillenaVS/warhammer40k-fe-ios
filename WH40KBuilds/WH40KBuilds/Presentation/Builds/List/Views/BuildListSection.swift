//
//  BuildListSection.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import SwiftUI

struct BuildListSectionView: View {
    let builds: [Build]
    let onView: (Build) -> Void
    let onTrash: (Build) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(
                    title: "List of Builds",
                    subtitle: "Quick access to your custom armies."
                )
                .padding(.vertical, 20)
                .padding(.horizontal, 8)

                ForEach(builds) { build in
                    BuildRowView(
                        build: build,
                        onView: { onView(build) },
                        onTrash: { onTrash(build) }
                    )
                }
            }
        }
    }
}
