//
//  ChatListItemView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI

struct ChatListItemView: View {
    
    var itemViewModel: ChatListItemViewModel
    
    var body: some View {
        HStack {
            Color.gray
                .opacity(0.2)
                .frame(width: 44, height: 44)
                .mask(Circle())
                .overlay {
                    Text(itemViewModel.avatar)
                        .font(.title)
                }
            VStack {
                HStack {
                    Text(itemViewModel.title)
                        .font(.headline)
                    if itemViewModel.remind {
                        Circle()
                            .fill(.red)
                            .frame(width: 8)
                            .padding(.horizontal, 2)
                    }
                    Spacer()
                    Text(itemViewModel.updateDate)
                        .font(.subheadline)
                        .opacity(0.9)
                }
                HStack {
                    Text(itemViewModel.subtitle)
                        .font(.subheadline)
                        .opacity(0.6)
                        .lineLimit(1)
                    Spacer()
                }
                .opacity(itemViewModel.remind ? 0.4 : 1)
            }
        }
        .overlay {
            NavigationLink {
                NavigationLazyView(ChatDetailView(conversation: itemViewModel.conversaiton))
            } label: {
                EmptyView()
            }
            .opacity(0)
        }
    }
}

// https://stackoverflow.com/questions/57594159/swiftui-navigationlink-loads-destination-view-immediately-without-clicking
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        // let _ = Self._printChanges()
        build()
    }
}
