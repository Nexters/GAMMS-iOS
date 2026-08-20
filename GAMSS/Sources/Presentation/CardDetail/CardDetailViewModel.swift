//
//  CardDetailViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import Combine
import Foundation

@MainActor
final class CardDetailViewModel: ObservableObject {
    @Published private(set) var card: Card?
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let cardId: Int
    private let getCardUseCase: GetCardUseCase

    init(cardId: Int, getCardUseCase: GetCardUseCase) {
        self.cardId = cardId
        self.getCardUseCase = getCardUseCase
    }

    /// 카드가 아직 없고(로딩 실패로 보여줄 게 없음) 알럿이 떠 있으면, 알럿의 "닫기"가 화면 자체를
    /// 닫아야 한다. 삭제 실패는 카드가 이미 있는 상태라 알럿의 보조 버튼이 "확인"이어야 한다.
    var isLoadFailureAlert: Bool {
        card == nil && alertMessage != nil
    }

    func loadCard() async {
        isLoading = true
        defer { isLoading = false }
        do {
            card = try await getCardUseCase.execute(cardId: cardId)
        } catch {
            alertMessage = "카드를 불러오지 못했어요"
        }
    }
}
