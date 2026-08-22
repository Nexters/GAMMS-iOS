//
//  MainTabView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

@Observable
final class ArchiveTabRequest {
    var pendingTab: MainTab?
}

@Observable
final class PendingCardResult {
    var card: Card?
    /// 카드를 띄운 ChatView가 자기 자신의 dismiss()를 등록해두는 자리. 카드 흐름이 완전히
    /// 끝났을 때(닫기 또는 버리고 아카이브 상세 확인까지) 이 클로저를 직접 호출해 pop시킨다.
    /// 값이 바뀌는 걸 반응형으로 관찰하는 방식은 실제로 안 불리는 경우가 있어 직접 호출로 바꿨다.
    var dismissPresenter: (() -> Void)?
}

struct MainTabView: View {
    @State private var selectedTab: MainTab = .home
    @State private var archiveTabRequest = ArchiveTabRequest()
    @State private var pendingCardResult = PendingCardResult()

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
                        ),
                        getTokenUsageUseCase: GetTokenUsageUseCase(
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
        .environment(archiveTabRequest)
        .environment(pendingCardResult)
        .onChange(of: archiveTabRequest.pendingTab) { _, newValue in
            guard let newValue else { return }
            selectedTab = newValue
            archiveTabRequest.pendingTab = nil
        }
        .fullScreenCover(item: Binding(
            get: { pendingCardResult.card },
            set: { newValue in
                pendingCardResult.card = newValue
                if newValue == nil {
                    pendingCardResult.dismissPresenter?()
                }
            }
        )) { card in
            CardResultView(
                card: card,
                viewModel: CardResultViewModel(),
                onComplete: {
                    pendingCardResult.card = nil
                    pendingCardResult.dismissPresenter?()
                },
                onDiscarded: { emotion in
                    archiveTabRequest.pendingTab = .archive
                }
            )
            .presentationBackground(.clear)
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
