//
//  ExportBuildToPDF.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 30/6/25.
//

import Foundation

struct ExportBuildToPDF {
    let exporter: BuildPDFExporter 
    
    func execute(build: Build) async throws -> URL {
        try await exporter.export(build: build)
    }
}
