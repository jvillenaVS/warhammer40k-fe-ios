//
//  FirestoreBuildRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Combine

final class FirestoreBuildRepository: BuildRepository {
    private let dataSource = FirestoreBuildDataSource()
    
    func fetchBuilds() -> AnyPublisher<[Build], Error> {
        dataSource.readAll()
    }
    
    func addBuild(_ build: Build) -> AnyPublisher<Void, Error> {
        dataSource.create(build)
    }
    
    func updateBuild(_ build: Build) -> AnyPublisher<Void, Error> {
        dataSource.update(build)
    }
    
    func deleteBuild(id: String) -> AnyPublisher<Void, Error> {
        dataSource.delete(id: id)
    }
}
