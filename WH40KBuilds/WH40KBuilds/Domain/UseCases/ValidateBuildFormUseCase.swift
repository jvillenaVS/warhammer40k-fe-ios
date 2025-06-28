//
//  ValidateBuildFormUseCase.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import Foundation

/// Resultado de la validación del formulario
struct BuildFormState {
    var isValid: Bool
    var errors: [Field: String] = [:]
    
    enum Field { case name, faction, commandPoints, totalPoints }
}

/// Reglas de negocio para crear un Build
struct ValidateBuildFormUseCase {
    func validate(name: String,
                  faction: String,
                  commandPoints: String,
                  totalPoints: String) -> BuildFormState {
        
        var errors: [BuildFormState.Field: String] = [:]
        
        // Name
        if name.trimmingCharacters(in: .whitespaces).count < 3 {
            errors[.name] = "Name must have at least 3 characters"
        }
        
        // Faction
        if faction.trimmingCharacters(in: .whitespaces).isEmpty {
            errors[.faction] = "Faction is required"
        }
        
        // Command Points
        if let cp = Int(commandPoints) {
            if !(0...12).contains(cp) { errors[.commandPoints] = "CP must be 0‑12" }
        } else {
            errors[.commandPoints] = "CP must be a number"
        }
        
        // Total Points
        if let tp = Int(totalPoints) {
            if tp <= 0 { errors[.totalPoints] = "Points must be positive" }
        } else {
            errors[.totalPoints] = "Points must be a number"
        }
        
        return BuildFormState(isValid: errors.isEmpty, errors: errors)
    }
}
