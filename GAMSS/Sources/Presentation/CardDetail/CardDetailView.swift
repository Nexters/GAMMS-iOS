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

    init(viewModel: CardDetailViewModel, onClose: @escaping () -> Void) {
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.colorBlack.opacity(0.7)
                .ignoresSafeArea()

            if let card = viewModel.card {
                ZStack(alignment: .topTrailing) {
                    CardView(card: card) {
                        bottomActions
                    }

                    closeButton
                        .padding(Spacing.spacing300)
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
            HStack(spacing: Spacing.spacing100) {
                OutlineButton(title: "기록 버리기") {
                    Task { await discardCard() }
                }
                // 대화보기는 이번 스코프에서 UI만 존재 — 탭해도 동작 없음.
                OutlineButton(title: "대화보기") {}
            }
            .disabled(viewModel.isLoading)

            // 공유하기도 이번 스코프에서 UI만 존재.
            Text("공유하기 >")
                .typography(.caption2)
                .foregroundStyle(Color.colorGray600)
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.colorGray950)
        }
        .accessibilityLabel("닫기")
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
