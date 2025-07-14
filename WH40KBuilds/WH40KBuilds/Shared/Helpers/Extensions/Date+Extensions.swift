//
//  Date+Extensions.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 13/7/25.
//

import Foundation

extension Date {
    func toFormattedString() -> String {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yyyy – hh:mm a"
        return df.string(from: self)
    }
}
