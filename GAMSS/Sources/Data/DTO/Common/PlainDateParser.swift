//
//  PlainDateParser.swift
//  GAMSS
//
//  Created by cchanmi on 8/15/26.
//

import Foundation

/// 서버가 시각 없이 "yyyy-MM-dd" 형태로만 보내는 날짜(카드의 date 필드 등)를 파싱한다.
/// DateFormatter는 동시 접근 안전성이 문서화되어 있지 않아(ISO8601FlexibleParser와 동일한 이유)
/// 인스턴스를 static으로 공유하지 않고 호출마다 새로 만든다.
enum PlainDateParser {
    static func date(from value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
