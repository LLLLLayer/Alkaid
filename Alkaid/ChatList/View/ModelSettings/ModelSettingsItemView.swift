//
//  ModelSettingsItemView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/1.
//

import SwiftUI

struct ModelSettingsItemView: View {
    
    let isUserInteractionEnabled: Bool
    
    @Bindable var viewModel: ModelSettingsViewModel
    
    @State var isPresented = false
    
    var body: some View {
        VStack {
            progressView
            modelInfoView
        }
    }
    
    var progressView: some View {
        VStack(spacing: 4) {
            HStack(alignment: .bottom) {
                Text(String(format: "%.2f", viewModel.progress * 100) + "%")
                    .monospacedDigit()
                    .font(.title)
                    .bold()
                Text(viewModel.progressDesc)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .opacity(0.8)
                    .padding(.vertical, 4)
                Spacer()
            }
            .padding(.top, 8)
            progressLineView
        }
        .onTapGesture {
            guard isUserInteractionEnabled else { return }
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            ModelSettingsView(viewModel: viewModel)
        }
    }
    
    var progressLineView: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                    .frame(width: size.width, height: 12)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .foregroundColor(AppSettings.shared.tintColor)
                    .frame(width: min(viewModel.progress * size.width, size.width), height: 12)
            }
            .frame(width: size.width, height: size.height, alignment: .center)
        }
        .frame(height: 12)
    }
    
    var modelInfoView: some View {
        HStack {
            Text(viewModel.selectedModelName)
            Spacer()
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .opacity(0.5)
    }
}
