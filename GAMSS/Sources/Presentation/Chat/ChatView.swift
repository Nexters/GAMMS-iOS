//
//  ChatView.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool

    private let conversationId: Int?
    private let initialSentMessage: SentMessage?

    init(
        viewModel: ChatViewModel,
        conversationId: Int?,
        initialSentMessage: SentMessage? = nil
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.conversationId = conversationId
        self.initialSentMessage = initialSentMessage
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageRow(message: message)
                            .id(message.id)
                    }
                }
                .padding()
            }
            // ScrollView가 키보드에 의해 축소/복원될 때
            // SwiftUI가 키보드 dismiss를 자연스럽게 처리하도록 한다.
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: viewModel.messages) { _, newMessages in
                scrollToBottom(proxy, messages: newMessages)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                composer
            }
        }
        .task {
            if let initialSentMessage {
                viewModel.seed(with: initialSentMessage)
            } else if let conversationId {
                await viewModel.load(conversationId: conversationId)
            }
        }
        .alert(
            viewModel.toastMessage ?? "",
            isPresented: Binding(
                get: {
                    viewModel.toastMessage != nil
                },
                set: {
                    if !$0 {
                        viewModel.toastMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {}
        }
    }

    private var composer: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField(
                "메시지를 입력하세요",
                text: $viewModel.input,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .focused($isInputFocused)
            .lineLimit(1...5)
            .onChange(of: viewModel.input) { _, newValue in
                handleInputChange(newValue)
            }

            Button("전송") {
                Task {
                    await viewModel.send()
                }
            }
            .disabled(
                viewModel.input
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
                || viewModel.isSending
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.background)
    }

    private func handleInputChange(_ newValue: String) {
        // return 입력 시 줄바꿈을 제거하고 키보드를 내린다.
        if newValue.hasSuffix("\n") {
            viewModel.input = String(newValue.dropLast())

            // 별도의 animation 없이 포커스만 해제한다.
            // keyboard dismiss와 layout animation이 충돌하는 것을 방지한다.
            isInputFocused = false
            return
        }

        let maxLength = ConversationSummaryPolicy.maxMessageLength

        if newValue.count > maxLength {
            viewModel.input = String(newValue.prefix(maxLength))
        }
    }

    private func scrollToBottom(
        _ proxy: ScrollViewProxy,
        messages: [Message]
    ) {
        guard let lastMessage = messages.last else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            proxy.scrollTo(
                lastMessage.id,
                anchor: .bottom
            )
        }
    }
}

private struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            switch message.sender {
            case .user:
                Spacer()

                bubble

            case let .character(emotion):
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(emotion.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    bubble
                }

                Spacer()
            }
        }
    }

    private var bubble: some View {
        Text(message.content)
            .padding(10)
            .background(background)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
    }

    private var background: Color {
        switch message.sender {
        case .user:
            .blue.opacity(0.2)

        case .character:
            .gray.opacity(0.2)
        }
    }
}

private struct PreviewConversationRepository: ConversationRepository {
    func sendMessage(
        conversationId: Int?,
        content: String,
        repliesToMessageId: Int?,
        contextSummary: String?
    ) async throws -> SentMessage {
        SentMessage(
            message: Message(
                id: 1,
                conversationId: 1,
                sender: .user,
                content: content,
                repliesToMessageId: nil
            ),
            commentStatus: .done,
            comments: [
                Message(
                    id: 2,
                    conversationId: 1,
                    sender: .character(.joy),
                    content: "반가워!",
                    repliesToMessageId: 1
                )
            ]
        )
    }

    func getMessages(
        conversationId: Int
    ) async throws -> [Message] {
        [
            Message(
                id: 1,
                conversationId: 1,
                sender: .user,
                content: "안녕",
                repliesToMessageId: nil
            ),
            Message(
                id: 2,
                conversationId: 1,
                sender: .character(.sadness),
                content: "안녕하세요! 오늘 하루는 어땠어요?",
                repliesToMessageId: 1
            )
        ]
    }

    func getConversations(
        date: String
    ) async throws -> [ConversationSummary] {
        [
            ConversationSummary(
                id: 1,
                title: "미리보기 채팅방",
                status: "ACTIVE",
                createdAt: date
            )
        ]
    }
}

private actor PreviewConversationSummaryStore: ConversationSummaryStore {
    func add(_ utterance: String) async {}

    func current() async -> String? {
        nil
    }

    func reset() async {}

    func restore(
        historicalUtterances: [String]
    ) async {}
}

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            sendMessageUseCase: SendMessageUseCase(
                conversationRepository: PreviewConversationRepository()
            ),
            getMessagesUseCase: GetMessagesUseCase(
                conversationRepository: PreviewConversationRepository()
            ),
            summaryStore: PreviewConversationSummaryStore()
        ),
        conversationId: 1
    )
}
