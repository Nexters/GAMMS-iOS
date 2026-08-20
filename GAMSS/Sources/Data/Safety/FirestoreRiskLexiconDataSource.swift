//
//  FirestoreRiskLexiconDataSource.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import FirebaseFirestore
import Foundation

enum RiskLexiconFetchError: Error {
    case documentNotFound
}

struct FirestoreRiskLexiconDataSource {
    func fetch() async throws -> RiskLexiconDTO {
        let snapshot = try await Firestore.firestore()
            .collection("app_config")
            .document("risk_lexicon")
            .getDocument(source: .server)

        guard snapshot.exists, let data = snapshot.data() else {
            throw RiskLexiconFetchError.documentNotFound
        }

        let json = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(RiskLexiconDTO.self, from: json)
    }
}
