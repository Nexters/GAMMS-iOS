//
//  ConversationEndpoint.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import Foundation

enum ConversationEndpoint: Endpoint {
    case saveMessage(SaveMessageRequestDTO)
    case getMessages(conversationId: Int)
    case getConversations(date: String)

    var path: String {
        switch self {
        case .saveMessage:
            return "/api/conversations/messages"
        case .getMessages(let conversationId):
            return "/api/conversations/\(conversationId)/messages"
        case .getConversations(let date):
            return "/api/conversations?date=\(date)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .saveMessage:
            return .post
        case .getMessages, .getConversations:
            return .get
        }
    }

    var parameters: [RequestParameter] {
        switch self {
        case .saveMessage(let request):
            return [.body(request)]
        case .getMessages, .getConversations:
            return []
        }
    }

    var header: HTTPHeader {
        .authorization
    }
}
