//
//  MessageView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI
import MarkdownUI

struct MessageView: View {
    
    let messageViewModel: MessageViewModel
    
    @State var fold = true
    
    var body: some View {
        if let message = messageViewModel.message {
            VStack {
                switch message.role {
                case .user, .system:
                    userMessageView
                case .assistant:
                    assistantMessageView
                }
            }.frame(minHeight: 40)
        } else {
            EmptyView()
        }
    }
    
    var userMessageView: some View {
        HStack {
            Spacer()
            Markdown(messageViewModel.content ?? "")
                .markdownTextStyle(textStyle: {
                    ForegroundColor(.white)
                })
                .textSelection(.enabled)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(AppSettings.shared.tintColor)
                .mask {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }
    }
    
    var assistantMessageView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let thinkingIsEmpty = messageViewModel.thinkingContent?.isEmpty ?? true
            if !thinkingIsEmpty {
                HStack {
                    thinkingText
                    Spacer()
                }
            }
            if !fold, !thinkingIsEmpty {
                thinkingContentView
            }
            if let content = messageViewModel.content {
                HStack {
                    Markdown(content)
                        .textSelection(.enabled)
                    Spacer()
                }
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    var thinkingText: some View {
        Group {
            if let thinkingState = messageViewModel.thinkingState {
                HStack {
                    Button {
                        fold.toggle()
                    } label: {
                        Image(systemName: fold ? "chevron.right" : "chevron.down")
                            .font(.system(size: 12))
                            .fontWeight(.medium)
                    }
                    .frame(width: 16)
                    Text(thinkingState)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
            } else {
                EmptyView()
            }
        }
    }
    
    var thinkingContentView: some View {
        HStack {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(.secondary)
                .frame(width: 3)
                .frame(maxHeight: .infinity)
            Markdown(messageViewModel.thinkingContent ?? "")
                .textSelection(.enabled)
                .markdownTextStyle {
                    ForegroundColor(.secondary)
                }
            Spacer()
        }
    }
}
