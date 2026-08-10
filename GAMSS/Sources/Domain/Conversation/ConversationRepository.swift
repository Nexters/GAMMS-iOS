//
//  ConversationRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

protocol ConversationRepository {
    /// conversationId가 nil이면 서버가 새 채팅방을 만든다.
    /// contextSummary는 저장되지 않고 캐릭터 응답 생성 컨텍스트로만 쓰인다.
    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage

    /// 작성순으로 온다. 화면이 이 순서에 의존한다.
    func getMessages(conversationId: Int) async throws -> [Message]

    /// 지정한 날짜(yyyy-MM-dd, KST 00:00~24:00)에 생성된 채팅방 목록을 반환한다.
    func getConversations(date: String) async throws -> [ConversationSummary]
}
