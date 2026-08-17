//
//  ConversationHistoryView.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import SwiftUI

/// 카드에 연결된 대화를 읽기 전용으로 보여준다. CardDetailView 안에서 CardView와 자리를
/// 바꿔가며 쓰인다 — 입력창/답장/자동 스크롤 같은 라이브 채팅 기능은 없다.
struct ConversationHistoryView: View {
    let card: Card
    let onBack: () -> Void
    let onClose: () -> Void

    @ObservedObject private var viewModel: ConversationHistoryViewModel

    private let panelSize = CGSize(width: 342, height: 505)

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
                header

                Spacer().frame(height: Spacing.spacing350)

                DashedDivider()

                Spacer().frame(height: Spacing.spacing300)

                messageList
            }
            .padding(.horizontal, Spacing.spacing400)
            .padding(.vertical, Spacing.spacing500)
            .frame(width: panelSize.width, height: panelSize.height)

            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView()
                    .tint(Color.colorGray900)
            }
        }
        .frame(width: panelSize.width, height: panelSize.height)
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

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.colorGray900)
            }
            .accessibilityLabel("뒤로가기")

            Spacer()

            Text(ConversationListDateHeaderFormatter.string(from: card.date))
                .typography(.subtitle3)
                .foregroundStyle(Color.colorGray900)

            Spacer()

            Button(action: onClose) {
                Image("cardCloseButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .accessibilityLabel("닫기")
        }
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
        }
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
