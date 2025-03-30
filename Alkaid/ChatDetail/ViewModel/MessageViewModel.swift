//
//  MessageViewModel.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/15.
//

import SwiftUI

@Observable
class MessageViewModel: Identifiable {
    
    let id: UUID
    
    let message: Message?
    
    let thinkingState: String?
    
    let thinkingContent: String?
    
    let content: String?
    
    let isThinking: Bool
    
    init(message: Message?, thinkingTime: TimeInterval? = nil) {
        self.id = message?.id ?? UUID()
        self.message = message
        self.isThinking = !(message?.content.contains("</think>") ?? false)
        switch message?.role {
        case .user:
            (self.thinkingContent, self.content) = (nil, message?.content)
        default:
            (self.thinkingContent, self.content) = message?.split() ?? (nil, nil)
        }
        self.thinkingState = Self.thinkingState(with: message, thinkingTime: thinkingTime) ?? nil
    }
    
    static private func thinkingState(
        with message: Message?,
        thinkingTime: TimeInterval?
    ) -> String? {
        // Has thinked.
        guard message?.content.range(of: "<think>") != nil else {
            return nil
        }
        let isThinking = if message?.thinkingTime != nil {
            false
        } else {
            !(message?.content.contains("</think>") ?? false)
        }
        let prefix = String(localized: isThinking ? "Thinking" : "ThoughtFor")
        let time = " \(Int(message?.thinkingTime ?? thinkingTime ?? 0)) "
        let suffix = String(localized:"Second")
        return prefix + time + suffix
    }
}

extension MessageViewModel {
    static let empty = MessageViewModel(message: nil)
}
