//
//  Message.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/1/31.
//

import Foundation
import SwiftData

enum Role: String, Codable {
    case user
    case system
    case assistant
}

@Model
class Message {
    
    @Attribute(.unique) var id: UUID
    
    var role: Role
    
    var content: String
    
    var timestamp: Date
    
    var generatingTime: TimeInterval?
    
    var thinkingTime: TimeInterval?
    
    var conversation: Conversation?
    
    init(
        id: UUID = UUID(),
        role: Role,
        content: String,
        timestamp: Date = Date(),
        generatingTime: TimeInterval? = nil,
        thinkingTime: TimeInterval? = nil,
        conversation: Conversation? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.generatingTime = generatingTime
        self.thinkingTime = thinkingTime
        self.conversation = conversation
    }
}

extension Message {
    
    func split() -> (thinkingContent: String?, content: String?) {
        
        guard let startRange = content.range(of: "<think>") else {
            return (nil, content.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        guard let endRange = content.range(of: "</think>") else {
            let thinkingContent = String(content[startRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return (thinkingContent, nil)
        }
        
        let thinkingContent = String(content[startRange.upperBound ..< endRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return (
            thinkingContent,
            String(content[endRange.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
