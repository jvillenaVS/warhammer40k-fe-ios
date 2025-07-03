//
//  ValidateBuildForm.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation

struct BuildFormState {
    var isValid: Bool
    var errors: [Field: String] = [:]
    enum Field: Hashable {
        case name, faction, subfaction, detachment
        case cp, points
        case hq, troops, elite, fast, heavy, flyers
    }
}

/// Reglas
struct ValidateBuildForm {
    func validate(values: FormValues) -> BuildFormState {
        var err: [BuildFormState.Field: String] = [:]
        
        // Build Info
        if values.name.trimmingCharacters(in: .whitespaces).count < 3 {
            err[.name] = "Min. 3 characters"
        }
        if values.faction.trimmingCharacters(in: .whitespaces).count < 3 {
            err[.faction] = "Min. 3 characters"
        }
        if values.subfaction.trimmingCharacters(in: .whitespaces).isEmpty {
            err[.subfaction] = "Required"
        }
        if values.detachment.trimmingCharacters(in: .whitespaces).isEmpty {
            err[.detachment] = "Required"
        }
        
        // Points
        if let cp = Int(values.cp) {
            if !(0...12).contains(cp) { err[.cp] = "0‑12" }
        } else { err[.cp] = "Number" }
        
        if let tp = Int(values.points) {
            if tp <= 0 { err[.points] = "Must be > 0" }
        } else { err[.points] = "Number" }
        
        // Slots (6 valores)
        for (field, str) in values.slots {
            if let val = Int(str) {
                if val < 0 { err[field] = "≥ 0" }
            } else { err[field] = "Number" }
        }
        return BuildFormState(isValid: err.isEmpty, errors: err)
    }
}



