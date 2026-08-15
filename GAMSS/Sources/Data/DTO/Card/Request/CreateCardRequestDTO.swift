//
//  CreateCardsRequestDTO.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

struct CreateCardRequestDTO: Encodable {
    let conversationId: Int
    /// 대표 감정을 판단할 수 없는 대화도 있어 nil을 허용한다.
    let emotion: String?
    let summary: String

    private enum CodingKeys: String, CodingKey {
        case conversationId, emotion, summary
    }

    // 합성 Encodable은 옵셔널이 nil이면 encodeIfPresent로 키 자체를 생략한다
    // (CreateMessageRequestDTO와 동일). 이 API는 반대로 emotion nil을 명시적 null로 기대해서
    // encodeNil로 직접 채운다.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(conversationId, forKey: .conversationId)
        if let emotion {
            try container.encode(emotion, forKey: .emotion)
        } else {
            try container.encodeNil(forKey: .emotion)
        }
        try container.encode(summary, forKey: .summary)
    }
}
