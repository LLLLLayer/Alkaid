//
//  ChatDetailViewModel.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI
import Combine

@Observable
class ChatDetailViewModel {
    
    @ObservationIgnored // It makes ChatDetailView update.
    private var cancellables = Set<AnyCancellable>()
    
    let conversaiton: Conversation
    
    private(set) var messageViewModels: [MessageViewModel] = []
    
    private(set) var isRunning: Bool = false
    
    private(set) var runningTime: TimeInterval?
    
    private(set) var thinkingTime: TimeInterval?
    
    private(set) var title: String = ""
    
    private(set) var output: String = "" {
        didSet {
            guard !output.isEmpty, isRunning else {
                outputMessageViewModel = MessageViewModel.empty
                return
            }
            let msg = Message(role: .assistant, content: output)
            outputMessageViewModel = MessageViewModel(message: msg, thinkingTime: thinkingTime)
        }
    }
    
    private(set) var outputMessageViewModel = MessageViewModel.empty
    
    var toast: String?
    
    init(conversaiton: Conversation) {
        self.conversaiton = conversaiton
        bind()
    }
}

// MARK: - Bind

extension ChatDetailViewModel {
    
    private func bind() {
        
        ReasoningService.shared.reasoningInfo.sink { [weak self] reasoningInfo in
            guard let self else { return }
            
            Task { @MainActor [weak self] in
                guard
                    let self,
                    reasoningInfo?.currentCid.uuidString == conversaiton.id.uuidString else {
                    return
                }
                isRunning = reasoningInfo?.isRunning ?? false
                runningTime = Date().timeIntervalSince(reasoningInfo?.startTime ?? Date())
                output = reasoningInfo?.output ?? ""
            }
            
        }.store(in: &cancellables)
        
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard
                    let self,
                    let startTime = ReasoningService.shared.reasoningInfo.value?.startTime else {
                    self?.runningTime = 0
                    return
                }
                runningTime = Date().timeIntervalSince(startTime)
                if outputMessageViewModel.isThinking {
                    thinkingTime = runningTime
                }
            }.store(in: &cancellables)
        
        let update = { [weak self] in
            guard let self else { return }
            messageViewModels = conversaiton.sortedMessages.map({ message in
                self.messageViewModels.first {
                    $0.id.uuidString == message.id.uuidString
                } ?? MessageViewModel(message: message)
            })
        }
        
        Task { @MainActor in
            NotificationCenter
                .default
                .publisher(
                    for: ChatService.ConversationMessagesUpdateNotification
                ).sink { [weak self] noti in
                    guard
                        let self,
                        let cid = noti.userInfo?[ChatService.ConversationIDKey] as? UUID,
                        cid == conversaiton.id else {
                        return
                    }
                    update()
                }.store(in: &cancellables)
        }
        update()
    }
}

// MARK: - Action

extension ChatDetailViewModel {
    
    func send(content: String) async {
        let userMsg = Message(
            role: .user,
            content: content,
            conversation: conversaiton)
        await ChatService.shared.send(userMsg)
        Task {
            let output = try? await ReasoningService.shared
                .generate(conversation: conversaiton)
            if let output {
                let assistantMsg = Message(
                    role: .assistant,
                    content: output,
                    generatingTime: runningTime,
                    thinkingTime: thinkingTime,
                    conversation: conversaiton)
                await ChatService.shared.send(assistantMsg)
            }
            ReasoningService.shared.clear()
        }
    }
    
    func cancel() {
        ReasoningService.shared.cancelled = true
    }
}

// MARK: - Cleaning

extension ChatDetailViewModel {
    
    /// Cleaning up the context
    func cleaningUpIfNeed() {
        guard
            let info = ReasoningService.shared.reasoningInfo.value,
            info.isRunning,
            info.currentCid.uuidString != conversaiton.id.uuidString else {
            return
        }
        ReasoningService.shared.cancelled = true
        toast = String(localized: "PreviousInterrupted")
    }
}
