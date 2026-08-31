//
//  SearchConversationUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import Foundation

protocol SearchConversationUseCase {
    func execute(_ text: String, page: Int, size: Int) async throws -> ConversationPage
}
