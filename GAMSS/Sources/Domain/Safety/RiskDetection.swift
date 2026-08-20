//
//  RiskDetection.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

struct RiskDetection: Equatable {
    let level: RiskLevel
    let agencies: [SupportAgency]

    var shouldBlock: Bool { level == .critical }

    static let none = RiskDetection(level: .none, agencies: [])
}
