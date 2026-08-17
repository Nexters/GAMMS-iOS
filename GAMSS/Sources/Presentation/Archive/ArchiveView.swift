//
//  ArchiveView.swift
//  GAMSS
//
//  Created by cchanmi on 8/10/26.
//

import SwiftUI

struct ArchiveView: View {
    @State private var isShowingCardDetail = false

    var body: some View {
        VStack {
            Spacer()

            Text("준비 중입니다")
                .typography(.body3Regular)
                .foregroundStyle(Color.colorGray500)

            // 카드 목록 화면이 아직 없어서 상세 화면을 확인해볼 임시 버튼.
            // 목록 화면이 생기면 실제 카드를 탭해서 들어가는 걸로 대체하고 이 버튼은 지운다.
            Button("카드 상세 보기 (임시)") {
                isShowingCardDetail = true
            }
            .padding(.top, Spacing.spacing300)

            Spacer()
        } // TODO: cardId 값 바인딩 필요
        .fullScreenCover(isPresented: $isShowingCardDetail) {
            CardDetailView(
                viewModel: CardDetailViewModel(
                    cardId: 28,
                    getCardUseCase: GetCardUseCase(cardRepository: DefaultCardRepository(networkManager: NetworkManager.shared)),
                    deleteCardUseCase: DeleteCardUseCase(cardRepository: DefaultCardRepository(networkManager: NetworkManager.shared))
                ),
                onClose: { isShowingCardDetail = false }
            )
            .presentationBackground(.clear)
        }
    }
}

#Preview {
    ArchiveView()
}
