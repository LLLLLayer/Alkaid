//
//  ModelSettingsView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI
import AlertToast

struct ModelSettingsView: View {
    
    @Bindable var viewModel: ModelSettingsViewModel
    
    @State var toast: Bool = false
    @State var toastText: String = ""
    
    var body: some View {
        VStack {
            VStack {
                ModelSettingsItemView(
                    isUserInteractionEnabled: false,
                    viewModel: viewModel)
                .fixedSize(horizontal: false, vertical: true)
                systemPromptsView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            
            List {
                if !viewModel.installedViewModels.isEmpty {
                    Section {
                        ForEach($viewModel.installedViewModels) { itemViewModel in
                            ModelInstalledItemView(itemViewModel: itemViewModel)
                                .onTapGesture { select(itemViewModel.wrappedValue) }
                        }
                    } header: {
                        Text("InstalledModels")
                    } footer: {
                        if viewModel.notInstalledViewModels.isEmpty {
                            Text("DynamicRemoteModelHelp")
                        } else {
                            EmptyView()
                        }
                    }
                }
                
                if !viewModel.notInstalledViewModels.isEmpty {
                    Section {
                        ForEach($viewModel.notInstalledViewModels) { itemViewModel in
                            ModelInstalledItemView(itemViewModel: itemViewModel)
                                .onTapGesture { select(itemViewModel.wrappedValue) }
                        }
                    } header: {
                        Text("NotInstalledModels")
                    } footer: {
                        Text("DynamicRemoteModelHelp")
                    }
                }
            }
        }
        .toast(isPresenting: $toast, duration: 2, alert: {
            AlertToast(displayMode: .alert,
                       type: .regular,
                       title: toastText)
        })
    }
    
    private var systemPromptsView: some View {
        HStack {
            Text("SystemPrompts")
                .font(.body)
                .fontWeight(.medium)
                .opacity(0.9)
            TextField("SystemPrompts", text: $viewModel.systemPrompts)
                .font(.body)
                .scrollDismissesKeyboard(.immediately)
                .submitLabel(.done)
                .opacity(0.8)
        }
        .padding(6)
        .background(.gray.opacity(0.1))
        .mask {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        }
    }
    
    private func select(_ itemViewModel: ModelInstalledItemViewModel) {
        Task {
            do {
                try await viewModel.select(itemViewModel)
            } catch {
                guard let error = error as? ModelSettingsViewModel.ModelSettingsError else {
                    return
                }
                toastText = error.description
                toast = true
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = ModelSettingsViewModel()
    ModelSettingsView(viewModel: viewModel)
}
