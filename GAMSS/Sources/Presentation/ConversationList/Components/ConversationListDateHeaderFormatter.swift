//
//  ConversationListDateHeaderFormatter.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

/// 날짜를 "26.08.13" 형식으로 포맷한다. 기기 로케일/타임존과 무관하게 한국 시간(KST) 기준으로
/// 고정. 대화방 목록 화면의 날짜 헤더(오늘 날짜 표시용, 목록 조회 자체와는 무관)와 채팅방 헤더에서 공유해 사용.
enum ConversationListDateHeaderFormatter {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yy.MM.dd"
        return formatter
    }()

    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
