//
//  BuildRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Combine

protocol BuildRepository {
    
    /// Devuelve un flujo en vivo con todos los builds del usuario.
    func fetchBuilds(for uid: String) -> AnyPublisher<[Build], Error>
    
    /// Crea un nuevo build.
    func addBuild(_ build: Build) -> AnyPublisher<Void, Error>
    
    /// Actualiza un build existente.
    func updateBuild(_ build: Build) -> AnyPublisher<Void, Error>
    
    /// Elimina un build por su documentID.
    func deleteBuild(id: String) -> AnyPublisher<Void, Error>
}


