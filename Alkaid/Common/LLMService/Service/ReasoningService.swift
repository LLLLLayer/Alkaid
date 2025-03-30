//
//  ReasoningService.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import Foundation
import Combine
import MLX
import MLXLLM
import MLXRandom
import MLXLMCommon

enum ReasoningError: Error {
    
    /// Model not loaded
    case noModelInstalled
}

struct ReasoningConfiguration {
    
    /// Maximum number of tokens
    let maxTokens = 4096
    
    /// Number of tokens displayed per second
    let displayEveryNTokens = 4
    
    /// Parameters for text generation
    let generateParameters = GenerateParameters(temperature: 0.6)
    
    /// System prompt words
    let systemPrompts: String?
    
    init(systemPrompts: String?) {
        self.systemPrompts = systemPrompts
    }
}

struct ReasoningInfo {
    
    /// The conversation ID of the current inference run
    let currentCid: UUID
    
    /// Is reasoning in progress
    let isRunning: Bool
    
    /// Inference start time
    let startTime: Date
    
    ///  Current inference output
    let output: String?
    
    init(
        currentCid: UUID,
        isRunning: Bool,
        startTime: Date,
        output: String?
    ) {
        self.currentCid = currentCid
        self.isRunning = isRunning
        self.startTime = startTime
        self.output = output
    }
    
    /// Copy a information that updates the necessary properties
    init(
        info: ReasoningInfo,
        currentCid: UUID? = nil,
        isRunning: Bool? = nil,
        startTime: Date? = nil,
        output: String? = nil
    ) {
        self.currentCid = currentCid ?? info.currentCid
        self.isRunning = isRunning ?? info.isRunning
        self.startTime = startTime ?? info.startTime
        self.output = output ?? info.output
    }
}

class ReasoningService {
    
    static let shared = ReasoningService()
    
    /// External call, cancel inference run
    var cancelled = false
    
    /// Current reasoning information
    let reasoningInfo = CurrentValueSubject<ReasoningInfo?, Never>(nil)
    
    /// System prompt words
    @UserDefault("systemPrompts", defaultValue: "")
    var systemPrompts
    
}

extension ReasoningService {
    
    func clear() {
        cancelled = false
        reasoningInfo.send(nil)
    }
    
    
    @discardableResult
    func generate(
        conversation: Conversation
    ) async throws -> String {
        guard case let .loaded(modelContext, modelContainer) = ModelService.shared.currentState else {
            throw ReasoningError.noModelInstalled
        }
        clear()
        reasoningInfo.send(
            ReasoningInfo(
                currentCid: conversation.id,
                isRunning: true,
                startTime: Date(),
                output: nil))
        
        let configuration = ReasoningConfiguration(systemPrompts: systemPrompts)
        let messages = conversation.getHistoricalContents(systemPrompt: systemPrompts)
        MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))
        let result = try await modelContainer.perform { context in
            let input = try await context.processor.prepare(input: .init(messages: messages))
            return try MLXLMCommon.generate(
                input: input,
                parameters: configuration.generateParameters,
                context: context
            ) { tokens in
                guard !cancelled, tokens.count < configuration.maxTokens else {
                    return .stop
                }
                if tokens.count % configuration.displayEveryNTokens == 0 {
                    let text = context.tokenizer.decode(tokens: tokens)
                    Task { @MainActor in
                        if let info = self.reasoningInfo.value {
                            let output = modifyOutpt(modelContext: modelContext, output: text, reasoning: true)
                            self.reasoningInfo.send(ReasoningInfo(info: info, output: output))
                        }
                    }
                }
                return .more
            }
        }
        
        let output = modifyOutpt(modelContext: modelContext, output: result.output, reasoning: false)
        if let info = self.reasoningInfo.value {
            reasoningInfo.send(ReasoningInfo(info: info, isRunning: false, output: output))
        }
        return output
    }
    
    private func modifyOutpt(modelContext: ModelContext, output: String, reasoning: Bool) -> String {
        guard modelContext.modelType == .thinking else { return output }
        let containThinkBegin = output.contains("<think>")
        let cintainThinkEnd = output.contains("</think>")
        switch (containThinkBegin, cintainThinkEnd) {
        case (true, _):
            return output
        case (false, true):
            return "<think>\n" + output
        case (false, false):
            return reasoning ? "<think>\n" + output : output
        }
    }
}

