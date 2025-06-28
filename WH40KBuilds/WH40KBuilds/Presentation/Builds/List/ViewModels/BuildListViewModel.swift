//
//  BuildListViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

@MainActor
final class BuildListViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var builds: [Build] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let repository: BuildRepository
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(repository: BuildRepository = FirestoreBuildRepository()) {
        self.repository = repository
        fetchBuilds()
    }
    
    // MARK: - Public Intents
    func fetchBuilds() {
        isLoading = true
        
        repository.fetchBuilds()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] builds in
                self?.builds = builds
                self?.isLoading = false
            }
            .store(in: &cancellables)
    }
    
    func addSampleBuild() {
        let sample = BuildFactory.sampleBuild()
        repository.addBuild(sample)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let id = builds[index].id else { return }
            repository.deleteBuild(id: id)
                .sink(receiveCompletion: { _ in }, receiveValue: { })
                .store(in: &cancellables)
        }
    }
}


