//
//  ChatDetailInputView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI

struct ChatDetailInputView: View {
    
    @Binding var viewModel: ChatDetailViewModel
    
    @State private var content: String = ""
    @FocusState private var isContentFocused: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {
            TextField("EnterGuide", text: $content, axis: .vertical)
                .focused($isContentFocused)
                .textFieldStyle(.plain)
            
            if !viewModel.isRunning {
                sendButton
            } else {
                cancelButton
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(16)
        .background(.background)
    }
    
    var sendButton: some View {
        Image(systemName: "arrow.up.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                .white,
                content.isEmpty ? .gray.opacity(0.2) : AppSettings.shared.tintColor)
            .onTapGesture { send() }
            .disabled(content.isEmpty)
    }
    
    var cancelButton: some View {
        Image(systemName: "stop.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, AppSettings.shared.tintColor)
            .onTapGesture { cancel() }
    }
    
    func send() {
        Task.detached { @MainActor in
            await viewModel.send(content: content)
            content = ""
        }
    }
    
    func cancel() {
        viewModel.cancel()
    }
}
