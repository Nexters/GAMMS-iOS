//
//  RiskLexiconDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

struct RiskLexiconDTO: Codable {
    let version: Int
    let terms: [RiskTermDTO]
    let safePhrases: [String]
    let agencies: [SupportAgencyDTO]
}

struct RiskTermDTO: Codable {
    let term: String
    let level: String
}

struct SupportAgencyDTO: Codable {
    let id: String
    let name: String
    let description: String
    let phoneNumber: String?
    let url: String?
    let priority: Int
}

extension RiskLexiconDTO {
    func toDomain() -> RiskLexicon {
        RiskLexicon(
            version: version,
            terms: terms.compactMap { $0.toDomain() },
            safePhrases: safePhrases.filter { !$0.isEmpty },
            agencies: agencies.map { $0.toDomain() }.sorted { $0.priority < $1.priority }
        )
    }
}

extension RiskTermDTO {
    func toDomain() -> RiskTerm? {
        guard !term.isEmpty else { return nil }
        let riskLevel: RiskLevel
        switch level.uppercased() {
        case "CRITICAL": riskLevel = .critical
        case "NONE": riskLevel = .none
        default: riskLevel = .warning
        }
        return RiskTerm(term: term, level: riskLevel)
    }
}

extension SupportAgencyDTO {
    func toDomain() -> SupportAgency {
        SupportAgency(id: id, name: name, description: description, phoneNumber: phoneNumber, url: url, priority: priority)
    }
}
