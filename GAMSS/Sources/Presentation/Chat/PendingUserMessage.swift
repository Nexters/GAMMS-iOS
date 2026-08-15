//
//  PendingUserMessage.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import Foundation

/// 서버 응답을 기다리는 동안 화면에 낙관적으로 보여주는 내 메시지. `Message`(Domain 엔티티,
/// 서버가 확정한 데이터)와 분리된 Presentation 전용 타입이다 — 서버가 아직 모르는 상태를
/// 표현하려고 `Message`에 `id: 0` 같은 가짜 identity를 채우지 않기 위함.
struct PendingUserMessage: Equatable {
    /// `ChatView`가 스크롤 대상으로 삼는 고정 id. 화면에 펜딩 메시지는 항상 최대 1개뿐이라
    /// 매번 새로 만들 필요 없이 상수 하나로 충분하다.
    static let scrollAnchorID = "pendingUserMessage"

    let content: String
    let sentAt: Date
}
