//
//  ConversationSummaryDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Foundation

struct ConversationSummaryDTO: Decodable {
    let id: Int
    let title: String?
    let status: String
    let createdAt: String
    let updatedAt: String

    /// createdAt 파싱에 실패하면 (다른 DTO들과 동일한 정책으로) 이 대화방을 목록에서 제외한다 —
    /// 잘못된 시간으로 표시하는 것보다 안전한 선택.
    func toDomain() -> ConversationSummary? {
        guard let createdAtDate = ISO8601FlexibleParser.date(from: createdAt) else { return nil }
        return ConversationSummary(id: id, title: title, status: status, createdAt: createdAtDate)
    }
}
