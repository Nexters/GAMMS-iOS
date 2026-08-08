//
//  ChatView.swift
//  GAMSS
//
//  Created by cchanmi on 8/7/26.
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    private let conversationId: Int?

    init(viewModel: ChatViewModel, conversationId: Int?) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.conversationId = conversationId
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages) { message in
                        MessageRow(message: message)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                TextField("메시지를 입력하세요", text: $viewModel.input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.input) { _, newValue in
                        if newValue.count > ConversationSummaryPolicy.maxMessageLength {
                            viewModel.input = String(newValue.prefix(ConversationSummaryPolicy.maxMessageLength))
                        }
                    }

                Button("전송") {
                    Task { await viewModel.send() }
                }
                .disabled(viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
            }
            .padding()
        }
        .task {
            if let conversationId {
                await viewModel.load(conversationId: conversationId)
            }
        }
        .alert(viewModel.toastMessage ?? "", isPresented: Binding(
            get: { viewModel.toastMessage != nil },
            set: { if !$0 { viewModel.toastMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        }
    }
}

private struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            if case .user = message.sender { Spacer() }
            Text(message.content)
                .padding(10)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            if case .character = message.sender { Spacer() }
        }
    }

    private var background: Color {
        switch message.sender {
        case .user: .blue.opacity(0.2)
        case .character: .gray.opacity(0.2)
        }
    }
}

private struct PreviewConversationRepository: ConversationRepository {
    func sendMessage(conversationId: Int?, content: String, repliesToMessageId: Int?, contextSummary: String?) async throws -> SentMessage {
        SentMessage(
            message: Message(id: 1, conversationId: 1, sender: .user, content: content, repliesToMessageId: nil),
            commentStatus: .done,
            comments: [
                Message(id: 2, conversationId: 1, sender: .character(.joy), content: "반가워!", repliesToMessageId: 1)
            ]
        )
    }

    func getMessages(conversationId: Int) async throws -> [Message] {
        [
            Message(id: 1, conversationId: 1, sender: .user, content: "안녕", repliesToMessageId: nil),
            Message(id: 2, conversationId: 1, sender: .character(.warm), content: "안녕하세요! 오늘 하루는 어땠어요?", repliesToMessageId: 1)
        ]
    }

    func getConversations(date: String) async throws -> [ConversationSummary] {
        [ConversationSummary(id: 1, title: "미리보기 채팅방", status: "ACTIVE", createdAt: date)]
    }
}

private actor PreviewConversationSummaryStore: ConversationSummaryStore {
    func add(_ utterance: String) async {}
    func current() async -> String? { nil }
    func reset() async {}
    func restore(historicalUtterances: [String]) async {}
}

#Preview {
    ChatView(
        viewModel: ChatViewModel(
            sendMessageUseCase: SendMessageUseCase(conversationRepository: PreviewConversationRepository()),
            getMessagesUseCase: GetMessagesUseCase(conversationRepository: PreviewConversationRepository()),
            summaryStore: PreviewConversationSummaryStore()
        ),
        conversationId: 1
    )
}
