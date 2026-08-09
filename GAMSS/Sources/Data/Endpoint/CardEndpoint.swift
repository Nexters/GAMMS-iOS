//
//  CardEndpoint.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

enum CardEndpoint: Endpoint {
    case fetchCards(date: String)
    case createCard(CreateCardRequestDTO)
    case deleteAllCards
    case fetchCard(cardId: String)
    case deleteCard(cardId: String)
    case fetchMonthlyCards(yearMonth: String)
    case deleteCardsByEmotion(emotion: String)
    
    var path: String {
        switch self {
        case .fetchCards:
            return "/api/cards"
        case .createCard:
            return "/api/cards"
        case .deleteAllCards:
            return "/api/cards"
        case let .fetchCard(cardId):
            return "/api/cards/\(cardId)"
        case let .deleteCard(cardId):
            return "/api/cards/\(cardId)"
        case .fetchMonthlyCards:
            return "/api/cards/monthly"
        case let .deleteCardsByEmotion(emotion):
            return "/api/cards/emotions/\(emotion)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchCards:
            return .get
        case .createCard:
            return .post
        case .deleteAllCards:
            return .delete
        case .fetchCard:
            return .get
        case .deleteCard:
            return .delete
        case .fetchMonthlyCards:
            return .get
        case .deleteCardsByEmotion:
            return .delete
        }
    }
    
    var parameters: [RequestParameter] {
        switch self {
        case .fetchCards(let date):
            return [.query(["date": date])]
        case .createCard(let request):
            return [.body(request)]
        case .deleteAllCards:
            return []
        case .fetchCard(let cardId):
            return []
        case .deleteCard(let cardId):
            return []
        case .fetchMonthlyCards(let yearMonth):
            return [.query(["yearMonth": yearMonth])]
        case .deleteCardsByEmotion(let emotion):
            return []
        }
    }
    
    var header: HTTPHeader {
        .authorization
    }
}
