//
//  ConversationRepository.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

protocol ConversationRepository {
    /// conversationId가 nil이면 서버가 새 채팅방을 만든다.
    /// contextSummary는 저장되지 않고 캐릭터 응답 생성 컨텍스트로만 쓰인다.
    /// excludedCharacters에 담긴 캐릭터는 이번 메시지에 응답하지 않도록 서버에 전달된다.
    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?, excludedCharacters: Set<EmotionCharacter>) async throws -> SentMessage

    /// 작성순으로 온다. 화면이 이 순서에 의존한다.
    func getMessages(conversationId: Int) async throws -> [Message]

    /// 아직 끝나지 않은(미완료) 채팅방 목록을 반환한다.
    func getIncompleteConversations() async throws -> [ConversationSummary]

    /// 대화방 제목을 설정한다. 홈에서 첫 메시지로 새 대화가 만들어진 직후, 그 메시지 내용을
    /// 그대로 제목으로 저장하는 데 쓰인다.
    func updateTitle(conversationId: Int, title: String) async throws

    /// 대화를 종료 처리한다. 이후 대화방 정리(감정 카드 생성 대상에서 제외 등)는 서버가 담당한다.
    func endConversation(conversationId: Int) async throws

    func deleteConversations(_ ids: [Int]) async throws
    func searchConversations(_ text: String, page: Int, size: Int) async throws -> ConversationPage
}
