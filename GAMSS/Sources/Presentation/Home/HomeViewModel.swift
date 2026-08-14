//
//  HomeViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var input: String = ""
    @Published private(set) var isSending = false
    @Published var alertMessage: String?
    @Published var createdConversationId: Int?
    @Published private(set) var createdSentMessage: SentMessage?
    @Published private(set) var selectedEmotions: Set<EmotionCharacter> = Set(EmotionCharacter.allCases)
    @Published var isEmotionPickerOpen = false

    private let sendMessageUseCase: SendMessageUseCase
    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let updateConversationTitleUseCase: UpdateConversationTitleUseCase
    private let userManager: UserManager

    /// 테스트에서 백그라운드 title 저장이 끝나는 시점을 결정적으로 기다리기 위한 핸들
    /// (ChatViewModel.pendingSummaryUpdateTask와 동일한 목적).
    private(set) var pendingTitleUpdateTask: Task<Void, Never>?

    init(
        sendMessageUseCase: SendMessageUseCase,
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        updateConversationTitleUseCase: UpdateConversationTitleUseCase,
        userManager: UserManager = .shared
    ) {
        self.sendMessageUseCase = sendMessageUseCase
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
        self.updateConversationTitleUseCase = updateConversationTitleUseCase
        self.userManager = userManager
    }

    /// 화면 진입 시 1회 호출한다. 이미 프로필이 있으면(다른 화면에서 이미 불러온 경우 등)
    /// 재조회하지 않는다 — 탭을 오갈 때마다 API를 다시 부르지 않기 위함.
    func loadProfileIfNeeded() async {
        guard userManager.user == nil else { return }
        do {
            userManager.user = try await fetchMyProfileUseCase.execute()
        } catch {
            alertMessage = "사용자 정보를 불러오지 못했어요"
        }
    }

    /// 입력창의 원시 입력값을 받아 정책에 맞게 정규화하고, 키보드를 내려야 하는지 돌려준다.
    func updateInput(_ rawValue: String) -> Bool {
        let result = ConversationSummaryPolicy.normalizeInput(rawValue)
        input = result.value
        return result.shouldDismissKeyboard
    }

    var isSendDisabled: Bool {
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending
    }

    /// 감정 선택을 토글한다. 최소 1개는 항상 선택되어 있어야 하므로, 마지막 1개를
    /// 해제하려는 시도는 무시한다.
    func toggleEmotion(_ emotion: EmotionCharacter) {
        if selectedEmotions.contains(emotion) {
            guard selectedEmotions.count > 1 else { return }
            selectedEmotions.remove(emotion)
        } else {
            selectedEmotions.insert(emotion)
        }
    }

    func send() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        isSending = true
        defer { isSending = false }

        do {
            let sent = try await sendMessageUseCase.execute(
                conversationId: nil,
                content: trimmed,
                repliesToMessageId: nil,
                contextSummary: nil,
                excludedCharacters: Set(EmotionCharacter.allCases).subtracting(selectedEmotions)
            )
            input = ""
            createdSentMessage = sent
            createdConversationId = sent.message.conversationId

            // 채팅 화면 이동은 위에서 이미 트리거됐다 — title 저장 완료를 기다리지 않고
            // 백그라운드에서 처리한다. self를 캡처하면 pendingTitleUpdateTask(self 소유)와
            // 순환 참조가 생기므로 weak로 잡는다.
            let conversationId = sent.message.conversationId
            let updateConversationTitleUseCase = updateConversationTitleUseCase
            pendingTitleUpdateTask = Task { [weak self] in
                do {
                    try await updateConversationTitleUseCase.execute(conversationId: conversationId, title: trimmed)
                } catch {
                    self?.alertMessage = "제목을 저장하지 못했어요"
                }
            }
        } catch let error as SendMessageValidationError {
            alertMessage = error.errorDescription
        } catch {
            alertMessage = "쪽지를 보내지 못했어요"
        }
    }
}
