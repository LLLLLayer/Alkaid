//
//  ChatDetailView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI
import AlertToast

struct ChatDetailView: View {
    
    @State var viewModel: ChatDetailViewModel
    
    @State var toast: Bool = false
    
    init(conversation: Conversation) {
        let viewModel = ChatDetailViewModel(conversaiton: conversation)
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // let _ = Self._printChanges()
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            VStack {
                ChatDetailListView(viewModel: $viewModel)
                    .frame(maxHeight: .infinity)
                ChatDetailInputView(viewModel: $viewModel)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $toast, duration: 2) {
            AlertToast(displayMode: .banner(.pop),
                       type: .regular,
                       title: String(localized: "Tips"),
                       subTitle: viewModel.toast,
                       style: .style(
                        backgroundColor: AppSettings.shared.tintColor,
                        titleColor: .white,
                        subTitleColor: .white,
                        titleFont: .headline,
                        subTitleFont: .footnote))
        }
        .onChange(of: viewModel.toast) { _, newValue in
            toast = !(newValue?.isEmpty ?? true)
        }
    }
}
