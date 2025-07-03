//
//  SharePDFView.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 30/6/25.
//

import SwiftUI
import UIKit

struct SharePDFView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let items: [Any] = [url]
        let vc = UIActivityViewController(activityItems: items,
                                          applicationActivities: [InstagramStoryActivity(url: url)])
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Custom UIActivity para “Share to Instagram Story”
final class InstagramStoryActivity: UIActivity {
    private let url: URL
    init(url: URL) { self.url = url }
    
    override var activityTitle: String? { "Instagram Story" }
    override var activityImage: UIImage? {
        UIImage(systemName: "camera.metering.center.weighted") }
    override class var activityCategory: UIActivity.Category { .share }
    
    override func canPerform(withActivityItems items: [Any]) -> Bool {
        UIApplication.shared.canOpenURL(URL(string: "instagram-stories://")!)
    }
    override func prepare(withActivityItems items: [Any]) { }
    
    override func perform() {
        guard let data = try? Data(contentsOf: url) else {
            activityDidFinish(false); return
        }
        
        // Acceso directo: no es opcional
        let pasteboard = UIPasteboard.general
        
        pasteboard.setItems(
            [["com.instagram.sharedSticker.backgroundImage": data]],
            options: [.expirationDate: Date().addingTimeInterval(5 * 60)]
        )
        
        UIApplication.shared.open(
            URL(string: "instagram-stories://share")!,
            options: [:]
        ) { success in
            self.activityDidFinish(success)
        }
    }
}
