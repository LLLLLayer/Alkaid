//
//  Conversation.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/1/31.
//

import Foundation
import SwiftData

@Model
class Conversation {
    
    @Attribute(.unique) var id: UUID
    
    var avatar: String
    
    var title: String?
    
    var createDate: Date
    
    var updateDate: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []
    
    var sortedMessages: [Message] {
        messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    init(
        id: UUID = UUID(),
        avatar: String = Conversation.randomAvatar(),
        title: String? = nil,
        createDate: Date = Date(),
        updateDate: Date = Date(),
        messages: [Message]
    ) {
        self.id = id
        self.avatar = avatar
        self.title = title
        self.createDate = createDate
        self.updateDate = updateDate
        self.messages = messages
    }
}

// MARK: - Avatar

extension Conversation {
    
    static let availableAvatars = [
        "😀", "🤩", "😍", "🥳", "😎",
        "😇", "🤯", "🤪", "🤣", "🤓",
        "👾", "🤡", "👻", "🤖", "😺",
        "🦁", "🐽", "🐮", "🦄", "🐤",
    ]
    
    static func randomAvatar() -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(availableAvatars.count)))
        return availableAvatars[randomIndex]
    }
}

// MARK: - HistoricalContents

extension Conversation {
    
    func getHistoricalContents(
        systemPrompt: String? = nil
    ) -> [[String: String]] {
        
        var history: [[String: String]] = []
        
        // SystemPrompt
        if let systemPrompt, !systemPrompt.isEmpty {
            history.append([
                "role": Role.system.rawValue,
                "content": systemPrompt,
            ])
        }
        
        // Messages
        for message in sortedMessages {
            let role = message.role.rawValue
            history.append([
                "role": role,
                "content": formatForTokenizer(message.content),
            ])
        }

        return history
    }
    
    func formatForTokenizer(_ message: String) -> String {
        return " " + message
            .replacingOccurrences(of: "<think>", with: "")
            .replacingOccurrences(of: "</think>", with: "")
    }
}

