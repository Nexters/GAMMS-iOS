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
            VStack(alignment: .leading, spacing: 0) {
                ConversationListHeaderView()
                    .padding(.horizontal, Spacing.spacing400)
                    .padding(.top, Spacing.spacing200)

                dateHeader
                    .padding(.horizontal, Spacing.spacing400)
                    .padding(.top, Spacing.spacing300)
                    .padding(.bottom, Spacing.spacing200)

                if !viewModel.isLoading && viewModel.conversations.isEmpty {
                    ConversationListEmptyView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.spacing100) {
                            ForEach(viewModel.conversations) { conversation in
                                NavigationLink(value: conversation) {
                                    ConversationRowView(conversation: conversation)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Spacing.spacing400)
                    }
                }
            }
            .navigationBarHidden(true)
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

    private var dateHeader: some View {
        HStack {
            Text(ConversationListDateHeaderFormatter.string(from: Date()))
                .typography(.body5Regular)
                .foregroundStyle(Color.colorGray500)

            Spacer()

            Text("삭제하기")
                .typography(.body5Regular)
                .foregroundStyle(Color.colorGray500)
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
