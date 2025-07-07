//
//  Mapping+Codex.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 7/7/25.
//

extension FactionCodex {
    func asRaw() -> RawFactionCodex {
        .init(id: id, name: name, iconUrl: iconUrl)
    }
    init(raw: RawFactionCodex) {
        self.init(id: raw.id, name: raw.name, iconUrl: raw.iconUrl)
    }
}

extension SubFactionCodex {
    func asRaw() -> RawSubFactionCodex {
        .init(id: id, name: name)
    }
    init(raw: RawSubFactionCodex) {
        self.init(id: raw.id, name: raw.name)
    }
}

extension DetachmentCodex {
    func asRaw() -> RawDetachmentCodex {
        .init(id: id, name: name, cpCost: cpCost, limits: limits)
    }
    init(raw: RawDetachmentCodex) {
        self.init(id: raw.id, name: raw.name, cpCost: raw.cpCost, limits: raw.limits)
    }
}
