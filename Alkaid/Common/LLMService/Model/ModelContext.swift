//
//  ModelContext.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import Foundation
import MLXLMCommon

class ModelContext: Identifiable {
    
    var id: String {
        modelType.rawValue + modelSource.rawValue + displayName
    }
    
    /// Wrappered MLX ModelConfiguration
    var modelConfiguration: ModelConfiguration
    
    /// Returns the model's type.
    var modelType: ModelType
    
    /// Returns the model's source.
    var modelSource: ModelSource
    
    /// Returns the model's approximate size, in GB.
    var modelSize: Double
    
    /// Returns the model's display name.
    var displayName: String
    
    init(
        modelConfiguration: ModelConfiguration,
        modelType: ModelType,
        modelSource: ModelSource,
        modelSize: Double,
        displayName: String
    ) {
        self.modelConfiguration = modelConfiguration
        self.modelType = modelType
        self.modelSource = modelSource
        self.modelSize = modelSize
        self.displayName = displayName
    }
}

extension ModelContext {
    
    enum ModelType: String {
        /// Default Model
        case `default`
        /// Thinking Model
        case thinking
    }
    
    enum ModelSource: String {
        /// Local model
        case local
        /// Remote model
        case remote
    }
}
