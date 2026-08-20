//
//  CardRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import Foundation

protocol CardRepository {
    /// emotion이 nil이면 대표 감정을 판단할 수 없었던 대화라는 뜻이고, 서버에도 그대로 null로 전달된다.
    func createCard(conversationId: Int, emotion: EmotionCharacter?, summary: String) async throws -> Card
    func getCard(cardId: Int) async throws -> Card
    func deleteCard(cardId: Int) async throws
    func fetchCardsByDate(yearMonth: Date, emotion: Emotion) async throws -> [DailyEmotion]
    func deleteAllCard() async throws
}
