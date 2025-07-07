//
//  SwiftUIPDFExporter.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 30/6/25.
//

import SwiftUI
import PDFKit

final class SwiftUIPDFExporter: BuildPDFExporter {
    
    /// Genera un PDF y devuelve la URL temporal.
    /// Ejecuta TODO el proceso en el Main Actor, evitando saltos y el
    /// problema de `Sendable`.
    @MainActor
    func export(build: Build) async throws -> URL {
        
        /// 1. Renderizar BuildPDFView a UIImage
        let renderer = ImageRenderer(content: BuildPDFView(build: build))
        renderer.scale = UIScreen.main.scale
        guard let image = renderer.uiImage else {        
            throw PDFExportError.renderFailed
        }
        
        // 2. Crear PDF
        let pdfData = NSMutableData()
        guard let consumer = CGDataConsumer(data: pdfData as CFMutableData) else {
            throw PDFExportError.contextFailed
        }
        var mediaBox = CGRect(origin: .zero, size: image.size)
        guard let ctx = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            throw PDFExportError.contextFailed
        }
        ctx.beginPDFPage(nil)
        ctx.draw(image.cgImage!, in: mediaBox)
        ctx.endPDFPage()
        ctx.closePDF()
        
        // 3. Guardar a /tmp
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pdf")
        try pdfData.write(to: tmpURL, options: .atomic)
        return tmpURL
    }
}

