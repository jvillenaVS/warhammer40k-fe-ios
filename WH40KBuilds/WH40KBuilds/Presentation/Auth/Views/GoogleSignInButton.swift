//
//  GoogleSignInButton.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 28/6/25.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButton: UIViewRepresentable {
    let action: () -> Void
    
    // MARK: - Coordinator
    class Coordinator: NSObject {
        let action: () -> Void
        init(action: @escaping () -> Void) { self.action = action }
        @objc func tapped() { action() }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UIView {
        // Contenedor para poder añadir el gesto si lo necesitas
        let container = UIView()
        
        let googleButton = GIDSignInButton()
        googleButton.style = .wide
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(googleButton)
        
        // Autolayout: que el botón llene el contenedor
        NSLayoutConstraint.activate([
            googleButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            googleButton.topAnchor.constraint(equalTo: container.topAnchor),
            googleButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // ✅ Gestor de toque: UITapGestureRecognizer
        let tap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.tapped)
        )
        container.addGestureRecognizer(tap)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Nada que actualizar
    }
}
