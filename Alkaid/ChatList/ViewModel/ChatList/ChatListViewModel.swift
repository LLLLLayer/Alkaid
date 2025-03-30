//
//  ChatListViewModel.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI
import Combine

@Observable
class ChatListViewModel {
    
    let title = String(localized: "Conversations")
    
    var items: [ChatListItemViewModel] = []
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            await load()
        }
    }
    
    private func load() async {
        let conversations = ChatService.shared.conversations
        conversations.sink { [weak self] conversations in
            guard let self else { return }
            items = conversations.map { conv in
                let cache = self.items.first {
                    $0.conversaiton.id == conv.id
                }
                return cache ?? ChatListItemViewModel(conversaiton: conv)
            }
        }.store(in: &cancellables)
    }
    
    func create() async {
        await ChatService.shared.createConversation()
    }
    
    func delete(_ item: ChatListItemViewModel) async {
        await ChatService.shared.delete(item.conversaiton)
    }
}
