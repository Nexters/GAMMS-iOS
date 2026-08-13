//
//  ISO8601FlexibleParser.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

/// 서버가 소수초를 포함해서 보낼 수도 있는 ISO8601 타임스탬프 문자열(예: "2026-08-07T00:00:00.123Z")을
/// 파싱한다. 화면에는 어차피 분 단위까지만 표시하므로 소수초 정밀도는 필요 없어, 포매터를 두 개 두고
/// 두 번 시도하는 대신 소수초 부분만 잘라내고 포매터 하나로 파싱한다. ISO8601DateFormatter는 동시 접근
/// 안전성이 문서화되어 있지 않아 인스턴스를 static으로 공유하지 않고 호출마다 새로 만든다 — 여러 DTO가
/// 동시에 디코딩될 수 있기 때문(예: 대화방 목록 로드와 메시지 히스토리 로드).
enum ISO8601FlexibleParser {
    static func date(from value: String) -> Date? {
        ISO8601DateFormatter().date(from: stripFractionalSeconds(value))
    }

    /// 소수초 부분(".123" 등)만 제거한다. 뒤에 타임존 지정자(Z/+/-)가 없어도 소수초 자체는
    /// 잘라내야 하므로, 그 존재를 전제하지 않고 "."부터 이어지는 숫자만 건너뛴다.
    private static func stripFractionalSeconds(_ value: String) -> String {
        guard let dotIndex = value.firstIndex(of: ".") else { return value }
        let afterDot = value[value.index(after: dotIndex)...]
        let suffixStart = afterDot.firstIndex(where: { !$0.isNumber }) ?? afterDot.endIndex
        return String(value[..<dotIndex]) + String(afterDot[suffixStart...])
    }
}
