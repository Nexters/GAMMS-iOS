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
                        MessageRow(
                            message: message,
                            quotedMessage: viewModel.quotedMessage(for: message)
                        )
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
    let quotedMessage: Message?

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
        VStack(alignment: .leading, spacing: 6) {
            if let quotedMessage {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quotedMessage.content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Divider()
                }
            }

            Text(message.content)
        }
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

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            sendMessageUseCase: SendMessageUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            ),
            getMessagesUseCase: GetMessagesUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            ),
            summaryStore: LazyConversationSummaryStore()
        ),
        conversationId: 1
    )
}
