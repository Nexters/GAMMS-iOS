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
        NavigationStack {
            TabView(selection: $selectedTab) {
                ArchiveView(viewModel: ArchiveViewModel())
                    .tabItem { tabLabel(for: .archive) }
                    .tag(MainTab.archive)

                HomeView(
                    viewModel: HomeViewModel(
                        fetchMyProfileUseCase: DefaultFetchMyProfileUseCase(
                            memberRepository: DefaultMemberRepository(networkManager: NetworkManager.shared, tokenStorage: .shared)
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
            }
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
