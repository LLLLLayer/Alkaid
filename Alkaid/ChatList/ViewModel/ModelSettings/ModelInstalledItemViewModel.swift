//
//  ModelInstalledItemViewModel.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI

@Observable
class ModelInstalledItemViewModel: Identifiable {
    
    @ObservationIgnored
    let modelContext: ModelContext
    
    @ObservationIgnored
    let modelName: String
    
    @ObservationIgnored
    let modelSize: String
    
    @ObservationIgnored
    let installed: Bool
    
    @ObservationIgnored
    let description: String
    
    var isLoading: Bool = false
    
    init(modelContext: ModelContext, installed: Bool) {
        self.modelContext = modelContext
        self.installed = installed
        self.modelName = modelContext.displayName
        self.modelSize = String(format: "%.1fGB", modelContext.modelSize)
        switch modelContext.modelSource {
        case .local:
            self.description = String(localized: "BuiltInLocalModel")
        case .remote:
            self.description = String(localized: "DynamicRemoteModel")
        }
    }
}
