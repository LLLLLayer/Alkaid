//
//  ModelService.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import Foundation
import Combine
import MLX
import MLXLLM
import MLXLMCommon
import Network

enum ModelError: Error {
    /// Model not found
    case noModelFound
    /// Repeated loading Model
    case repeatedLoad
}

class ModelService {
    
    static let shared = ModelService()
    
    /// The model that the user last selected
    @UserDefault(Keys.lastSeletedModelIdentifier.rawValue, defaultValue: defaultModelName)
    private(set) var lastSeletedModelIdentifier: String
    
    /// All available model contexts.
    let availableModelContexts = ModelService.availableModelContexts
    
    /// Model state.
    var currentState: State { _state.value }
    var state: AnyPublisher<State, Never> { _state.eraseToAnyPublisher() }
    private var _state = CurrentValueSubject<State, Never>(.idle)
    
    /// Installed models.
    var installedModels: AnyPublisher<[ModelContext], Never> {
        _installedModels.eraseToAnyPublisher()
    }
    private let _installedModels = CurrentValueSubject<[ModelContext], Never>([])
    
    private init() {
        loadInstalledModels()
    }
}

// MARK: - ModelState

extension ModelService {
    
    enum State {
        /// Not loaded
        case idle
        /// Loading
        case loading(Progress)
        /// Loading completed
        case loaded(ModelContext, ModelContainer)
    }
    
    @discardableResult
    func load(_ modelContext: ModelContext) async throws -> ModelContainer? {
        _state.send(.idle)
        MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)
        lastSeletedModelIdentifier = modelContext.id
        let configuration = modelContext.modelConfiguration
        let modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: configuration
        ) { [weak self] progress in
            guard let self else { return }
            _state.send(.loading(progress))
        }
        _state.send(.loaded(modelContext, modelContainer))
        appendInstalledModels(with: modelContext.id)
        return modelContainer
    }
}

// MARK: - InstalledModels

private extension ModelService {
    
    private func modelContext(for modelName: String) -> ModelContext? {
        availableModelContexts.first {
            $0.modelConfiguration.name == modelName
        }
    }
    
    private func loadInstalledModels() {
        let key = Keys.installedModels.rawValue
        let modelNames = UserDefaults.standard.stringArray(forKey: key) ?? []
        let installedModels = availableModelContexts.filter { context in
            modelNames.contains { $0 == context.id }
        }
        _installedModels.send(installedModels)
    }
    
    private func appendInstalledModels(with modelName: String) {
        let key = Keys.installedModels.rawValue
        var modelNames = UserDefaults.standard.stringArray(forKey: key) ?? []
        guard !modelNames.contains(modelName) else { return }
        modelNames.append(modelName)
        UserDefaults.standard.set(modelNames, forKey: key)
        loadInstalledModels()
    }
}

// MARK: - AvailableModelContexts

private extension ModelService {
    
    static let defaultModelName = LocalModels.deepseek_r1_distill_qwen_1_5b_4bit.id
    
    static let availableModelContexts: [ModelContext] = [
        /* LocalModels */
        LocalModels.deepseek_r1_distill_qwen_1_5b_4bit,
        /* RemoteModels */
        RemoteModels.deepseek_r1_distill_qwen_1_5b_3bit,
        // Replaced with local version
        // RemoteModels.deepseek_r1_distill_qwen_1_5b_4bit,
        RemoteModels.deepseek_r1_distill_qwen_1_5b_6bit,
        RemoteModels.deepseek_r1_distill_qwen_1_5b_8bit,
        // Performance is under pressure
        // , deepseek_r1_distill_qwen_1_5b_bf16,
        RemoteModels.llama_3_2_1b_4bit,
        RemoteModels.llama_3_2_3b_4bit,
    ]
    
    enum LocalModels {
        static let deepseek_r1_distill_qwen_1_5b_4bit = {
            let directory = Bundle.main.bundleURL.appending(
                path: "DeepSeek-R1-Distill-Qwen-1.5B-4bit")
            let modelConfiguration = ModelConfiguration(
                directory: directory,
                overrideTokenizer: nil,
                defaultPrompt: ""
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .thinking,
                modelSource: .local,
                modelSize: 1.0,
                displayName: "DeepSeek-R1-Distill-Qwen-1.5B-4bit")
        }()
    }
    
    enum RemoteModels {
        static let deepseek_r1_distill_qwen_1_5b_3bit = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-3bit"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .thinking,
                modelSource: .remote,
                modelSize: 0.8,
                displayName: "DeepSeek-R1-Distill-Qwen-1.5B-3bit")
        }()

        static let deepseek_r1_distill_qwen_1_5b_4bit = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-4bit"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .thinking,
                modelSource: .remote,
                modelSize: 1.0,
                displayName: "DeepSeek-R1-Distill-Qwen-1.5B-4bit")
        }()
        
        static let deepseek_r1_distill_qwen_1_5b_6bit = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-6bit"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .thinking,
                modelSource: .remote,
                modelSize: 1.4,
                displayName: "DeepSeek-R1-Distill-Qwen-1.5B-6bit")
        }()
        

        static let deepseek_r1_distill_qwen_1_5b_8bit = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-8bit"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .thinking,
                modelSource: .remote,
                modelSize: 1.9,
                displayName: "DeepSeek-R1-Distill-Qwen-1.5B-8bit")
        }()
        
        static let deepseek_r1_distill_qwen_1_5b_bf16 = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/DeepSeek-R1-Distill-Qwen-1.5B-bf16"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .thinking,
                modelSource: .remote,
                modelSize: 3.6,
                displayName: "DeepSeek-R1-Distill-Qwen-1.5B-bf16")
        }()
        
        static let llama_3_2_1b_4bit = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/Llama-3.2-1B-Instruct-4bit"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .default,
                modelSource: .remote,
                modelSize: 0.7,
                displayName: "Llama-3.2-1B-Instruct-4bit")
        }()

        static let llama_3_2_3b_4bit = {
            let modelConfiguration = ModelConfiguration(
                id: "mlx-community/Llama-3.2-3B-Instruct-4bit"
            )
            return ModelContext(
                modelConfiguration: modelConfiguration,
                modelType: .default,
                modelSource: .remote,
                modelSize: 1.8,
                displayName: "Llama-3.2-3B-Instruct-4bit")
        }()
    }
}


// MARK: - Keys

extension ModelService {
    
    enum Keys: String {
        /// Installed Models
        case installedModels
        /// The name of the model that was last selected
        case lastSeletedModelIdentifier
    }
}
