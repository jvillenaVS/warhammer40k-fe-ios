//
//  BuildPDFExporter.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 30/6/25.
//

import Foundation

protocol BuildPDFExporter {
   
    func export(build: Build) async throws -> URL
}
