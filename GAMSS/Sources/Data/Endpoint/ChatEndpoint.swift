//
//  ChatEndpoint.swift
//  GAMSS
//
//  Created by 이건준 on 8/8/26.
//

import Foundation

enum ChatEndpoint: Endpoint {
    case endChat(chatId: Int)
    case createMessage(CreateMessageRequestDTO)
    case createComment(CreateCommentRequestDTO)
    case createReply(messageId: Int)
    case updateTitle(chatId: String, UpdateChatTitleRequestDTO)
    case fetchChats(date: String)
    case fetchMessages(chatId: String)
    case searchChats(keyword: String, page: Int, size: Int)
    case fetchIncompleteChats
    case deleteChat(chatId: String)
    
    var path: String {
        switch self {
        case let .endChat(chatId):
            return "/api/conversations/\(chatId)/end"
        case .createMessage:
            return "/api/conversations/messages"
        case .createComment:
            return "/api/conversations/messages/comments"
        case let .createReply(messageId):
            return "/api/conversations/messages/comments/\(messageId)"
        case let .updateTitle(chatId, _):
            return "/api/conversations/\(chatId)/title"
        case .fetchChats:
            return "/api/conversations"
        case let .fetchMessages(chatId):
            return "/api/conversations/\(chatId)/messages"
        case .searchChats:
            return "/api/conversations/search"
        case .fetchIncompleteChats:
            return "/api/conversations/incomplete"
        case let .deleteChat(chatId):
            return "/api/conversations/\(chatId)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .endChat,
             .createMessage,
             .createComment,
             .createReply:
            return .post
        case .updateTitle:
            return .patch
        case .fetchChats,
             .fetchMessages,
             .searchChats,
             .fetchIncompleteChats:
            return .get
        case .deleteChat:
            return .delete
        }
    }
    
    var parameters: [RequestParameter] {
        switch self {
        case .endChat:
            return []
        case .createMessage(let request):
            return [.body(request)]
        case .createComment(let request):
            return [.body(request)]
        case .createReply:
            return []
        case let .updateTitle(_, request):
            return [.body(request)]
        case .fetchChats(let date):
            return [.query(["date": date])]
        case .fetchMessages:
            return []
        case let .searchChats(keyword, page, size):
            return [.query(["keyword": keyword, "page": "\(page)", "size": "\(size)"])]
        case .fetchIncompleteChats:
            return []
        case .deleteChat:
            return []
        }
    }
    
    var header: HTTPHeader {
        .authorization
    }
}
