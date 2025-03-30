//
//  ModelSettingsViewModel.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI
import Combine

@Observable
class ModelSettingsViewModel {
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    private(set) var state = State.idle
    
    private(set) var progress: Double = 0
    
    private(set) var progressDesc: String = ""
    
    private(set) var title = String(localized: "ModelSettings")
    
    var installedViewModels = [ModelInstalledItemViewModel]()
    
    var notInstalledViewModels = [ModelInstalledItemViewModel]()
    
    var selectedModelName: String = String(localized: "InstallGuide")
    
    var selectedModelSize: String?
    
    var systemPrompts: String = ReasoningService.shared.systemPrompts {
        didSet {
            ReasoningService.shared.systemPrompts = systemPrompts
        }
    }
    
    init() {
        
        // Installed
        ModelService.shared.installedModels.sink { [weak self] modelContexts in
            guard let self else { return }
            updateModelNames(with: modelContexts)
        }.store(in: &cancellables)
        
        // Model state
        ModelService.shared.state.sink { [weak self] state in
            Task { @MainActor [weak self] in
                guard let self else { return }
                switch state {
                case .idle:
                    self.progress = 0
                    self.progressDesc = String(localized: "StateIdle")
                    self.state = .idle
                case .loading(let progress):
                    let value = min(progress.fractionCompleted, 0.9999)
                    self.progress = value
                    self.progressDesc = String(localized: "StateLoading")
                    self.state = .loading(value)
                case .loaded:
                    self.progress = 1
                    self.progressDesc = String(localized: "StateLoaded")
                    self.state = .loaded
                }
            }
        }.store(in: &cancellables)
        
        // Defult install
        let identifier = ModelService.shared.lastSeletedModelIdentifier
        let viewModel = (installedViewModels + notInstalledViewModels).first {
            $0.modelContext.id == identifier
        } ?? installedViewModels.first
        if let viewModel {
            Task { try? await select(viewModel) }
        }
    }
    
    private func updateModelNames(with installedModels: [ModelContext]) {
        // Installed
        installedViewModels = installedModels.map {
            ModelInstalledItemViewModel(modelContext: $0, installed: true)
        }
        // Not installed
        notInstalledViewModels =
        ModelService.shared.availableModelContexts.filter { modelContext in
            !installedViewModels.contains { installedViewModel in
                modelContext.modelConfiguration.name ==
                installedViewModel.modelContext.modelConfiguration.name
            }
        }.map {
            ModelInstalledItemViewModel(modelContext: $0, installed: false)
        }
    }
}

extension ModelSettingsViewModel {
    
    func select(_ itemViewModel: ModelInstalledItemViewModel) async throws {
        if case .loading(_) = ModelService.shared.currentState {
            throw ModelSettingsError.conflict
        }
        itemViewModel.isLoading = true
        defer { itemViewModel.isLoading = false }
        selectedModelName = itemViewModel.modelName
        selectedModelSize = itemViewModel.modelSize
        do {
            let _ = try await ModelService.shared.load(
                itemViewModel.modelContext)
        } catch {
            throw ModelSettingsError.custom
        }
    }
}

extension ModelSettingsViewModel {
    
    enum ModelSettingsError: Error {
        case conflict
        case custom
        
        var description: String {
            switch self {
            case .conflict, .custom:
                String(localized: "PleaseTryLater")
            }
        }
    }
    
    enum State {
        case idle
        case loading(Double)
        case loaded
    }
}
