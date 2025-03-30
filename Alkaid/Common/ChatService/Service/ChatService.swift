//
//  ChatService.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import Foundation
import Combine
import SwiftData

class ChatService {
    
    static let shared = ChatService()
    
    var conversations: AnyPublisher<[Conversation], Never> {
        _conversations.eraseToAnyPublisher()
    }
    
    private let _conversations = CurrentValueSubject<[Conversation], Never>([])
    
    private let modelContainer: ModelContainer
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        do {
            let configuration = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true)
            modelContainer = try ModelContainer(
                for: Conversation.self, Message.self,
                configurations: configuration)

        } catch {
            fatalError("Couldn't create ModelContainer, error: \(error)")
        }
        bind()
        Task { @MainActor in
            modelContainer.mainContext.autosaveEnabled = true
            loadConversations()
        }
    }
    
    private func bind() {
        NotificationCenter
            .default
            .publisher(
                for: ChatService.ConversationUpdateNotification
            ).sink { [weak self] noti in
                guard let self else { return }
                let conversations = _conversations.value
                let newValue = conversations.sorted {
                    $0.updateDate.timeIntervalSince1970 > $1.updateDate.timeIntervalSince1970
                }
                _conversations.send(newValue)
                
            }.store(in: &cancellables)
    }
}

// MARK: - Conversation

extension ChatService {
    
    @MainActor
    @discardableResult
    private func loadConversations() -> [Conversation] {
        let sortDescriptor = SortDescriptor<Conversation>(\.updateDate, order: .reverse)
        let descriptor = FetchDescriptor<Conversation>(sortBy: [sortDescriptor])
        let convs = (try? modelContainer.mainContext.fetch(descriptor)) ?? []
        _conversations.send(convs)
        return convs
    }
    
    @MainActor
    @discardableResult
    func createConversation() async -> Conversation {
        let newConv = Conversation(messages: [])
        modelContainer.mainContext.insert(newConv)
        try? modelContainer.mainContext.save()
        var convs = _conversations.value
        convs.insert(newConv, at: 0)
        _conversations.send(convs)
        return newConv
    }
    
    @MainActor
    func delete(_ conversation: Conversation) {
        var convs = _conversations.value
        convs.removeAll { $0 === conversation }
        modelContainer.mainContext.delete(conversation)
        try? modelContainer.mainContext.save()
        _conversations.send(convs)
    }
}

// MARK: - Message

extension ChatService {
    
    @MainActor
    func send(_ message: Message) async {
        
        guard let conversation = message.conversation else { return }
        
        // Insert message.
        modelContainer.mainContext.insert(message)
         try? modelContainer.mainContext.save()
        
        // Notify messages have been update.
        NotificationCenter.default.post(
            name: ChatService.ConversationMessagesUpdateNotification,
            object: nil,
            userInfo: [
                ChatService.ConversationIDKey : conversation.id
            ])
        
        // Update conversation.
        guard let conversation = message.conversation else { return }
        if conversation.title == nil {
            conversation.title = message.content
            conversation.updateDate = message.timestamp
        }
        
        // Notify conversation has been update.
        NotificationCenter.default.post(
            name: ChatService.ConversationUpdateNotification,
            object: nil,
            userInfo: [
                ChatService.ConversationIDKey : conversation.id
            ])
    }
}

// MARK: - Notify

extension ChatService {
    
    ///The session information has changed
    static let ConversationUpdateNotification =
    Notification.Name("ConversationUpdateNotification")
    
    /// The message in the conversation has changed
    static let ConversationMessagesUpdateNotification =
    Notification.Name("ConversationMessagesUpdateNotification")
    
    static let ConversationIDKey = "ConversationIDKey"
}
