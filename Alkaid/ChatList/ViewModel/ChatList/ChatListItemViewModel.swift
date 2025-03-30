//
//  ChatListItemViewModel.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI
import Combine

@Observable
class ChatListItemViewModel: Identifiable {
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    let conversaiton: Conversation
    
    private(set) var avatar = ""
    
    private(set) var title = String(localized: "ChatTitlePlaceholder")
    
    private(set) var subtitle = String(localized: "ChatSubtitlePlaceholder")
    
    private(set) var updateDate = ""
    
    private(set) var remind = false
    
    init(conversaiton: Conversation) {
        self.conversaiton = conversaiton
        bind()
        render()
    }
    
    private func bind() {
        NotificationCenter
            .default
            .publisher(
                for: ChatService.ConversationUpdateNotification
            ).sink { [weak self] noti in
                guard
                    let self,
                    let cid = noti.userInfo?[ChatService.ConversationIDKey] as? UUID,
                    cid == conversaiton.id else {
                    return
                }
                render()
            }.store(in: &cancellables)
    }
    
    private func render() {
        avatar = conversaiton.avatar
        remind = conversaiton.messages.isEmpty
        
        if let title = conversaiton.title {
            self.title = title
        }
        
        if let lastMessage = conversaiton.sortedMessages.last {
            let (thinkingContent, content) = lastMessage.split()
            let subtitle = (thinkingContent ?? "") + (content ?? "")
            if !subtitle.isEmpty {
                self.subtitle = subtitle
            }
        }
        
        var time = conversaiton.createDate
        if let lastMessage = conversaiton.sortedMessages.last {
            time = lastMessage.timestamp
        }
        updateDate = formatDate(time)
    }
}

extension ChatListItemViewModel {
    
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: Date()) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        } else {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month, .day], from: date)
            let month = components.month ?? 0
            let day = components.day ?? 0
            return String(localized: "\(month)/\(day)")
        }
    }
}
