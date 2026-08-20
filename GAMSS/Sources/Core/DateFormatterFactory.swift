//
//  DateFormatterFactory.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import Foundation

enum DateFormatterFactory {
    private static func dateFormatter(locale: Locale = Locale(identifier: "ko_KR")) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        return formatter
    }

    /// `yyyy.MM`
    static var dateWithDot: DateFormatter {
        let formatter = dateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }
    
    /// `yyyy-MM-dd`
    static var dateWithHypen: DateFormatter {
        let formatter = dateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    /// `yyyy-MM`
    static var yearMonthWithHypen: DateFormatter {
        let formatter = dateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }
}
