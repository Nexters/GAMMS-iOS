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
    @Published var alertMessage: String?
    @Published var pendingFirstMessage: PendingFirstMessage?
    @Published private(set) var selectedEmotions: Set<EmotionCharacter> = Set(EmotionCharacter.allCases)
    @Published var isEmotionPickerOpen = false

    private let fetchMyProfileUseCase: FetchMyProfileUseCase
    private let userManager: UserManager

    init(
        fetchMyProfileUseCase: FetchMyProfileUseCase,
        userManager: UserManager = .shared
    ) {
        self.fetchMyProfileUseCase = fetchMyProfileUseCase
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
        input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedEmotions.isEmpty
    }

    /// 감정 선택을 토글한다. 전체 해제(0개)도 허용한다 — 그 경우 `isSendDisabled`가 true가
    /// 되어 전송 버튼이 비활성화되는 방식으로 "최소 1개 선택" 제약을 강제한다.
    func toggleEmotion(_ emotion: EmotionCharacter) {
        if selectedEmotions.contains(emotion) {
            selectedEmotions.remove(emotion)
        } else {
            selectedEmotions.insert(emotion)
        }
    }

    /// 서버 응답을 기다리지 않고 채팅 화면으로 바로 넘어간다 — 실제 전송/제목 저장은
    /// ChatViewModel이 화면 진입 직후 pendingFirstMessage로 자동 시작한다.
    func send() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard trimmed.count <= ConversationSummaryPolicy.maxMessageLength else {
            alertMessage = SendMessageValidationError.tooLong.errorDescription
            return
        }
        guard !selectedEmotions.isEmpty else { return }

        input = ""
        pendingFirstMessage = PendingFirstMessage(
            content: trimmed,
            excludedCharacters: Set(EmotionCharacter.allCases).subtracting(selectedEmotions)
        )
    }
}
