//
//  ChatDetailListView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI

struct ChatDetailListView: View {
    
    @Binding var viewModel: ChatDetailViewModel
    
    @State var autoScroll = true
    
    @State var scrollPosition: String?
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    // Messages
                    ForEach(viewModel.messageViewModels) { messageViewModel in
                        MessageView(messageViewModel: messageViewModel)
                            .id(messageViewModel.id.uuidString)
                    }
                    // Output
                    if viewModel.outputMessageViewModel.message != nil {
                        MessageView(messageViewModel: viewModel.outputMessageViewModel, fold: false)
                            .id(Constants.outputID)
                    }
                    // Bottom
                    Color.clear.frame(height: 1)
                        .id(Constants.bottomID)
                }
                .scrollTargetLayout()
            }
            .defaultScrollAnchor(.bottom)
            .scrollDismissesKeyboard(.interactively)
            .scrollPosition(id: $scrollPosition, anchor: .bottom)
            .onChange(of: viewModel.output) { oldValue, newValue in
                if autoScroll {
                    scrollViewProxy.scrollTo(Constants.bottomID, anchor: .bottom)
                }
            }
            .onChange(of: scrollPosition) { _, newValue in
                autoScroll = newValue == Constants.bottomID
            }
            // Open the keyboard and automatically scroll to the bottom
            .onReceive(NotificationCenter
                .default
                .publisher(for: UIResponder.keyboardDidShowNotification)
            ) { _ in
                withAnimation {
                    scrollViewProxy.scrollTo(Constants.bottomID, anchor: .bottom)
                }
            }
        }.onAppear {
            viewModel.cleaningUpIfNeed()
        }
    }
}

extension ChatDetailListView {
    
    enum Constants {
        static let outputID = "outputID"
        static let bottomID = "bottomID"
    }
}
