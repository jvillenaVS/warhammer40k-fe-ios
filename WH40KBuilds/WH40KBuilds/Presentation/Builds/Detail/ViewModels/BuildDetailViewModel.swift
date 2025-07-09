//
//  BuildDetailViewModel.swift
//  WH40KBuilds
//
//  Created by Jose Villena on 27/6/25.
//

import Foundation
import Combine

@MainActor
final class BuildDetailViewModel: ObservableObject {
    @Published var build: Build
    @Published var errorMessage: String?
    @Published var showingError: Bool = false
    @Published var pdfURL: URL?
    
    private let session: SessionStore?
    private let repository: BuildRepository
    private var cancellables = Set<AnyCancellable>()
    
    init(build: Build, repository: BuildRepository,
         session: SessionStore) {
        self.build = build
        self.repository  = repository
        self.session = session
    }
    
    func saveChanges() {
        repository.updateBuild(build)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage  = error.localizedDescription
                    self?.showingError = true
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
    
    func exportPDF() {
        Task {
            do {
                let url = try await ExportBuildToPDF(
                    exporter: SwiftUIPDFExporter()
                ).execute(build: build)
                pdfURL = url             
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

