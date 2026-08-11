//
//  MessageTimestampFormatter.swift
//  GAMSS
//
//  Created by cchanmi on 8/12/26.
//

import Foundation

/// 채팅 메시지 타임스탬프를 "오후 1:37" 형식으로 포맷한다. 기기 로케일/타임존과 무관하게
/// 한국어 표기로 고정 — 앱 UI가 전부 한국어이기 때문. DateFormatter는 생성 비용이 커서
/// static으로 캐싱해 메시지 행마다 새로 만들지 않는다.
enum MessageTimestampFormatter {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
