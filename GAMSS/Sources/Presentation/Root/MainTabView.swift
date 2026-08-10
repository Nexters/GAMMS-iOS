//
//  MainTabView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView(
                viewModel: HomeViewModel(
                    sendMessageUseCase: SendMessageUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    )
                )
            )
            .tabItem { Label("홈", systemImage: "house") }

            ConversationListView(
                viewModel: ConversationListViewModel(
                    getConversationsUseCase: GetConversationsUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    )
                )
            )
            .tabItem { Label("대화", systemImage: "bubble.left.and.bubble.right") }
        }
    }
}

#Preview {
    MainTabView()
}
