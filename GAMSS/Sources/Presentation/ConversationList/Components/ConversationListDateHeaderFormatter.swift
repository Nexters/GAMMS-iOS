//
//  ConversationListDateHeaderFormatter.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

/// 대화방 목록 화면의 날짜 헤더를 "26.08.13" 형식으로 포맷한다. 기기 로케일/타임존과 무관하게
/// 한국 시간(KST) 기준으로 고정 — `ConversationListViewModel`이 오늘 날짜를 조회할 때 쓰는 기준과
/// 동일하다. DateFormatter는 생성 비용이 커서 static으로 캐싱한다.
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
