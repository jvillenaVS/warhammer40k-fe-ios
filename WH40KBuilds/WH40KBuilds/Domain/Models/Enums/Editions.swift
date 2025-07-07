//
//  Editions.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

enum Edition: String, CaseIterable, Identifiable, Codable {
    case ninth = "9e"
    case tenth = "10e"

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .ninth: "9th Edition"
        case .tenth: "10th Edition"
        }
    }
}
