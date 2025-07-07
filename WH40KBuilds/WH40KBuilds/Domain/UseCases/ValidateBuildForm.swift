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

/// Revisa reglas de negocio del formulario y devuelve `BuildFormState`
struct ValidateBuildForm {
    
    /// Valida todos los campos del formulario
    /// - Parameters:
    ///   - values: struct con los valores escritos por el usuario
    ///   - detachment: límites de slots (opcional: nil si aún no eligió)
    func validate(values v: FormValues,
                  detachment: DetachmentCodex?) -> BuildFormState {
        
        var errors: [BuildFormState.Field : String] = [:]
        
        // ── 1. Reglas básicas de texto ───────────────────────────
        if v.name.trimmingCharacters(in: .whitespaces).count < 3 {
            errors[.name] = "≥ 3 chars"
        }
        if v.faction.isEmpty {
            errors[.faction] = "Choose a faction"
        }
        
        // ── 2. Command & Total points ───────────────────────────
        if let cp = Int(v.cp), cp < 0 {
            errors[.cp] = "≥ 0"
        } else if Int(v.cp) == nil {
            errors[.cp] = "Number"
        }
        
        if let pts = Int(v.points), pts <= 0 {
            errors[.points] = "> 0"
        } else if Int(v.points) == nil {
            errors[.points] = "Number"
        }
        
        // ── 3. Slots contra límites de detachment ───────────────
        if let det = detachment {
            checkSlot(.hq,     v.slots[.hq],     det.limits.hq,          &errors)
            checkSlot(.troops, v.slots[.troops], det.limits.troops,      &errors)
            checkSlot(.elite,  v.slots[.elite],  det.limits.elite,       &errors)
            checkSlot(.fast,   v.slots[.fast],   det.limits.fastAttack,  &errors)
            checkSlot(.heavy,  v.slots[.heavy],  det.limits.heavySupport,&errors)
            checkSlot(.flyers, v.slots[.flyers], det.limits.flyers,      &errors)
        }
        
        return BuildFormState(isValid: errors.isEmpty, errors: errors)
    }
    
    // MARK: Helper para límite min‑max
    private func checkSlot(_ field: BuildFormState.Field,
                           _ valueStr: String?,
                           _ limit: MinMax,
                           _ errors: inout [BuildFormState.Field : String]) {
        guard let v = Int(valueStr ?? "") else {
            errors[field] = "Number"; return
        }
        if v < limit.min || v > limit.max {
            errors[field] = "\(limit.min)‑\(limit.max)"
        }
    }
}



