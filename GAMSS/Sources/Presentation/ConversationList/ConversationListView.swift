//
//  ConversationListView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

struct ConversationListView: View {
    @StateObject private var viewModel: ConversationListViewModel
    @Binding private var isTabBarHidden: Bool

    init(viewModel: ConversationListViewModel, isTabBarHidden: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isTabBarHidden = isTabBarHidden
    }

    var body: some View {
        NavigationStack {
            List(viewModel.conversations) { conversation in
                NavigationLink(value: conversation) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(conversation.title ?? "제목 없음")
                        Text(conversation.status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("오늘의 채팅방")
            .navigationDestination(for: ConversationSummary.self) { conversation in
                ChatView(
                    viewModel: ChatViewModel(
                        sendMessageUseCase: SendMessageUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        getMessagesUseCase: GetMessagesUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        summaryStore: LazyConversationSummaryStore(),
                        conversationId: conversation.id
                    )
                )
                .onAppear { isTabBarHidden = true }
                .onDisappear { isTabBarHidden = false }
            }
        }
        .task {
            await viewModel.load()
        }
        .alert(viewModel.alertMessage ?? "", isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        }
    }
}

#Preview {
    ConversationListView(
        viewModel: ConversationListViewModel(
            getConversationsUseCase: GetConversationsUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            )
        ),
        isTabBarHidden: .constant(false)
    )
}
