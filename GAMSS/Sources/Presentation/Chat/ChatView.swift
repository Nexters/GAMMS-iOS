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

    init(viewModel: ChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: Spacing.spacing200) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message,
                                quotedMessage: viewModel.quotedMessage(for: message),
                                maxWidth: MessageBubbleLayout.maxBubbleWidth(
                                    availableWidth: geometry.size.width,
                                    containerPadding: Spacing.spacing300 * 2
                                )
                            )
                            .id(message.id)
                        }
                    }
                    .padding(Spacing.spacing300)
                }
                // ScrollView가 키보드에 의해 축소/복원될 때
                // SwiftUI가 키보드 dismiss를 자연스럽게 처리하도록 한다.
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: viewModel.messages) { _, newMessages in
                    scrollToBottom(proxy, messages: newMessages)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    ChatComposerView(
                        text: $viewModel.input,
                        isSendDisabled: viewModel.isSendDisabled,
                        onSend: { Task { await viewModel.send() } },
                        onTextChange: { viewModel.updateInput($0) },
                        isFocused: $isInputFocused
                    )
                }
            }
        }
        .task {
            await viewModel.start()
        }
        .alert(
            viewModel.alertMessage ?? "",
            isPresented: Binding(
                get: {
                    viewModel.alertMessage != nil
                },
                set: {
                    if !$0 {
                        viewModel.alertMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {}
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

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            sendMessageUseCase: SendMessageUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            ),
            getMessagesUseCase: GetMessagesUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            ),
            summaryStore: LazyConversationSummaryStore(),
            conversationId: 1
        )
    )
}
