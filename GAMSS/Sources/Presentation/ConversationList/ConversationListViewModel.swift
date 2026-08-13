//
//  ConversationListViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Combine
import Foundation

@MainActor
final class ConversationListViewModel: ObservableObject {
    @Published private(set) var conversations: [ConversationSummary] = []
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?

    private let getConversationsUseCase: GetConversationsUseCase

    init(getConversationsUseCase: GetConversationsUseCase) {
        self.getConversationsUseCase = getConversationsUseCase
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            conversations = try await getConversationsUseCase.execute(date: Self.todayDateString())
        } catch {
            alertMessage = "채팅방 목록을 불러오지 못했어요"
        }
    }

    private static func todayDateString() -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
