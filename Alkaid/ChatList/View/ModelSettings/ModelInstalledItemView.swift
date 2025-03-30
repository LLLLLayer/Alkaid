//
//  ModelInstalledItemView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/2/2.
//

import SwiftUI

struct ModelInstalledItemView: View {
    
    @Binding var itemViewModel: ModelInstalledItemViewModel
    
    var body: some View {
        HStack {
            if !itemViewModel.isLoading {
                let imageName = itemViewModel.installed ? "checkmark.circle" : "circle"
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(AppSettings.shared.tintColor)
                    .frame(width: 20)
            } else {
                ProgressView().frame(width: 20)
            }
            VStack {
                HStack {
                    Text(itemViewModel.modelName)
                        .font(.subheadline)
                    Spacer()
                    Text(itemViewModel.modelSize)
                        .font(.headline)
                        .bold()
                }
                HStack {
                    Text(itemViewModel.description)
                        .font(.footnote)
                        .opacity(0.5)
                    Spacer()
                }
            }
        }.padding(.vertical, 4)
    }
}
