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

    /// 아직 끝나지 않은(미완료) 채팅방 목록을 반환한다.
    func getIncompleteConversations() async throws -> [ConversationSummary]

    /// 대화방 제목을 설정한다. 홈에서 첫 메시지로 새 대화가 만들어진 직후, 그 메시지 내용을
    /// 그대로 제목으로 저장하는 데 쓰인다.
    func updateTitle(conversationId: Int, title: String) async throws
}
