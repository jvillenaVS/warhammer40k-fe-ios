//
//  BuildRepository.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

protocol BuildRepository {
    func fetchBuilds() -> AnyPublisher<[Build], Error>
    func addBuild(_ build: Build) -> AnyPublisher<Void, Error>
    func updateBuild(_ build: Build) -> AnyPublisher<Void, Error>
    func deleteBuild(id: String) -> AnyPublisher<Void, Error>
}
