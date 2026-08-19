//
//  CardDetailView.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import SwiftUI

struct CardDetailView: View {
    let onClose: () -> Void

    @StateObject private var viewModel: CardDetailViewModel
    @StateObject private var conversationHistoryViewModel: ConversationHistoryViewModel
    @State private var isShowingConversation = false

    private let transitionDuration = 0.22

    init(viewModel: CardDetailViewModel, onClose: @escaping () -> Void) {
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: viewModel)
        _conversationHistoryViewModel = StateObject(
            wrappedValue: ConversationHistoryViewModel(
                getMessagesUseCase: GetMessagesUseCase(
                    conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
                )
            )
        )
    }

    var body: some View {
        ZStack {
            Color.colorBlack.opacity(0.7)
                .ignoresSafeArea()

            if let card = viewModel.card {
                if isShowingConversation {
                    ConversationHistoryView(
                        card: card,
                        viewModel: conversationHistoryViewModel,
                        onBack: { showCard() },
                        onClose: onClose
                    )
                    .transition(.scale.combined(with: .opacity))
                } else {
                    ZStack(alignment: .topTrailing) {
                        CardView(card: card) {
                            bottomActions
                        }

                        closeButton
                            .padding([.top, .trailing], Spacing.spacing300)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .tint(Color.colorWhite)
            }
        }
        .task {
            await viewModel.loadCard()
        }
        .alert(
            viewModel.alertMessage ?? "",
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )
        ) {
            Button("다시 시도") {
                let isLoadFailure = viewModel.isLoadFailureAlert
                Task {
                    if isLoadFailure {
                        await viewModel.loadCard()
                    } else {
                        await discardCard()
                    }
                }
            }
            if viewModel.isLoadFailureAlert {
                Button("닫기", role: .cancel) { onClose() }
            } else {
                Button("확인", role: .cancel) {}
            }
        }
    }

    private var bottomActions: some View {
        VStack(spacing: Spacing.spacing200) {
            HStack(spacing: Spacing.spacing050) {
                OutlineButton(title: "기록 버리기") {
                    Task { await discardCard() }
                }
                .frame(width: 97)

                OutlineButton(title: "대화보기") {
                    showConversation()
                }
                .frame(width: 97)
            }
            .disabled(viewModel.isLoading)

            HStack(spacing: Spacing.spacing025) {
                Text("공유하기")
                    .typography(.caption2)
                    .foregroundStyle(Color.colorGray600)

                Image("cardShareChevron")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
        }
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

    private func showConversation() {
        withAnimation(.easeOut(duration: transitionDuration)) {
            isShowingConversation = true
        }
    }

    private func showCard() {
        withAnimation(.easeOut(duration: transitionDuration)) {
            isShowingConversation = false
        }
    }

    private func discardCard() async {
        let succeeded = await viewModel.deleteCard()
        if succeeded {
            onClose()
        }
    }
}

#Preview {
    CardDetailView(
        viewModel: CardDetailViewModel(
            cardId: 1,
            getCardUseCase: GetCardUseCase(cardRepository: DefaultCardRepository(networkManager: NetworkManager.shared)),
            deleteCardUseCase: DeleteCardUseCase(cardRepository: DefaultCardRepository(networkManager: NetworkManager.shared))
        ),
        onClose: {}
    )
}
