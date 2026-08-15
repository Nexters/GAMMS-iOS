//
//  MainTabView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home

    init() {
        let appearance = UITabBarAppearance()
        let font = UIFont(name: FontWeight.medium.postScriptName(), size: Typography.caption3.metrics.fontSize)

        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.colorWhite)

        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.colorGray950)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.colorGray950),
            .font: font as Any
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.colorGray300)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.colorGray300),
            .font: font as Any
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                viewModel: HomeViewModel(
                    sendMessageUseCase: SendMessageUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    ),
                    fetchMyProfileUseCase: DefaultFetchMyProfileUseCase(
                        memberRepository: DefaultMemberRepository(networkManager: NetworkManager.shared, tokenStorage: .shared)
                    ),
                    updateConversationTitleUseCase: UpdateConversationTitleUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    )
                )
            )
            .tabItem { tabLabel(for: .home) }
            .tag(MainTab.home)

            ConversationListView(
                viewModel: ConversationListViewModel(
                    getIncompleteConversationsUseCase: GetIncompleteConversationsUseCase(
                        conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                    ), deleteConversationsUseCase: DefaultDeleteConversationsUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)), searchConversationUseCase: DefaultSearchConversationUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared))
                )
            )
            .tabItem { tabLabel(for: .chat) }
            .tag(MainTab.chat)

            // 보관함 탭은 아직 노출하지 않음 — Figma 시안에서 당장 필요 없다고 확인됨.
            // MainTab.archive case와 ArchiveView는 그대로 남겨두었으니, 실제 기능이 붙는 시점에
            // 여기 .tabItem을 추가하기만 하면 된다 (임의로 다시 추가하지 말 것).
        }
    }

    @ViewBuilder
    private func tabLabel(for tab: MainTab) -> some View {
        Image(tab.iconName).renderingMode(.template)
        Text(tab.title)
    }
}

#Preview {
    MainTabView()
}
