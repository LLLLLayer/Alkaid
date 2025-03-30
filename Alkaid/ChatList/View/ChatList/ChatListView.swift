//
//  ChatListView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI

struct ChatListView: View {
    
    @State var viewModel = ChatListViewModel()
    
    @State var modelSettingsViewModel = ModelSettingsViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    Section {
                        ModelSettingsItemView(
                            isUserInteractionEnabled: true,
                            viewModel: modelSettingsViewModel)
                    } header: {
                        EmptyView()
                    } footer: {
                        if viewModel.items.isEmpty {
                            Text("ChatListGuide")
                        } else {
                            EmptyView()
                        }
                    }
                    
                    // ChatListGuide
                    Section {
                        ForEach(
                            $viewModel.items,
                            editActions: .delete
                        ) { $itemViewModel in
                            ChatListItemView(itemViewModel: itemViewModel)
                        }
                        .onDelete { delete($0) }
                    }
                }
                .listSectionSpacing(16)
            }
            .navigationTitle(viewModel.title)
            .toolbar {
                addButton
            }
        }
    }
    
    private var addButton: some View {
        Button {
            Task {
                await viewModel.create()
            }
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private func delete(_ indexSet: IndexSet) {
        let itemViewModels = indexSet.map { index in
            viewModel.items[index]
        }
        itemViewModels.forEach { itemViewModel in
            Task {
                await viewModel.delete(itemViewModel)
            }
        }
    }
}

#Preview {
    ChatListView()
}
