//
//  ContentView.swift
//  Alkaid
//
//  Created by yangjie.layer on 2025/1/31.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            ChatListView()
        } detail: {
            ChatDetailGuideView()
        }
    }
}

#Preview {
    ContentView()
}
