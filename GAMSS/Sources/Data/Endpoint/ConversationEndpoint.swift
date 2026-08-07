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

    var path: String {
        switch self {
        case .saveMessage:
            return "/api/conversations/messages"
        case .getMessages(let conversationId):
            return "/api/conversations/\(conversationId)/messages"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .saveMessage:
            return .post
        case .getMessages:
            return .get
        }
    }

    var body: Encodable? {
        switch self {
        case .saveMessage(let request):
            return request
        case .getMessages:
            return nil
        }
    }
}
