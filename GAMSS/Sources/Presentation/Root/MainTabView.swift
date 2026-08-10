//
//  MainTabView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var isTabBarHidden = false

    var body: some View {
        ZStack(alignment: .bottom) {
            content

            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, Spacing.spacing400)
                .padding(.bottom, Spacing.spacing200)
                .opacity(isTabBarHidden ? 0 : 1)
                .allowsHitTesting(!isTabBarHidden)
                .animation(.easeInOut(duration: 0.15), value: isTabBarHidden)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .archive:
            ArchiveView()

        case .home:
            HomeView(
                viewModel: HomeViewModel(
                    sendMessageUseCase: SendMessageUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    )
                ),
                isTabBarHidden: $isTabBarHidden
            )

        case .chat:
            ConversationListView(
                viewModel: ConversationListViewModel(
                    getConversationsUseCase: GetConversationsUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    )
                ),
                isTabBarHidden: $isTabBarHidden
            )
        }
    }
}

#Preview {
    MainTabView()
}
