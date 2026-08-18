//
//  ConversationHistoryView.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import SwiftUI

struct ConversationHistoryView: View {
    let card: Card
    let onBack: () -> Void
    let onClose: () -> Void

    @ObservedObject private var viewModel: ConversationHistoryViewModel

    private let panelSize = CGSize(width: 342, height: 505)

    private let headerSideInset: CGFloat = 36
    private let dividerHorizontalInset: CGFloat = 36
    private let bottomDividerInset: CGFloat = 30
    private let topContentOffset: CGFloat = 64

    init(card: Card, viewModel: ConversationHistoryViewModel, onBack: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.card = card
        self.onBack = onBack
        self.onClose = onClose
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Image("cardPaperBackground")
                .resizable()
                .frame(width: panelSize.width, height: panelSize.height)

            VStack(spacing: 0) {
                Spacer().frame(height: topContentOffset)

                DashedDivider()
                    .padding(.horizontal, dividerHorizontalInset)

                Spacer().frame(height: Spacing.spacing200)

                messageList

                Spacer().frame(height: Spacing.spacing200)

                DashedDivider()
                    .padding(.horizontal, dividerHorizontalInset)
            }
            .padding(.bottom, bottomDividerInset)
            .frame(width: panelSize.width, height: panelSize.height)

            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView()
                    .tint(Color.colorGray900)
            }
        }
        .frame(width: panelSize.width, height: panelSize.height)
        .overlay(alignment: .topLeading) {
            backButton
                .padding(.top, Spacing.spacing550)
                .padding(.leading, headerSideInset)
        }
        .overlay(alignment: .top) {
            dateText
                .padding(.top, Spacing.spacing550)
        }
        .overlay(alignment: .topTrailing) {
            closeButton
                .padding(.top, Spacing.spacing300)
                .padding(.trailing, Spacing.spacing300)
        }
        .task {
            await viewModel.loadMessagesIfNeeded(conversationId: card.conversationId)
        }
        .alert(
            viewModel.alertMessage ?? "",
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )
        ) {
            Button("다시 시도") {
                Task { await viewModel.retryLoad(conversationId: card.conversationId) }
            }
            Button("확인", role: .cancel) { onBack() }
        }
    }

    private var backButton: some View {
        Button(action: onBack) {
            Image(systemName: "chevron.left")
                .foregroundStyle(Color.colorGray900)
        }
        .accessibilityLabel("뒤로가기")
    }

    private var dateText: some View {
        Text(ConversationListDateHeaderFormatter.string(from: card.date))
            .typography(.subtitle3)
            .foregroundStyle(Color.colorGray900)
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image("cardCloseButton")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
        .accessibilityLabel("닫기")
    }

    private var messageList: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.spacing200) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            quotedMessage: viewModel.quotedMessage(for: message),
                            maxWidth: MessageBubbleLayout.maxBubbleWidth(
                                availableWidth: geometry.size.width,
                                containerPadding: 0
                            )
                        )
                        .id(message.id)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, Spacing.spacing400)
    }
}

#Preview {
    ZStack {
        Color.colorBlack.opacity(0.7).ignoresSafeArea()
        ConversationHistoryView(
            card: Card(id: 1, conversationId: 10, emotion: .sadness, summary: "요약", message: "메시지", date: Date()),
            viewModel: ConversationHistoryViewModel(
                getMessagesUseCase: GetMessagesUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared))
            ),
            onBack: {},
            onClose: {}
        )
    }
}
