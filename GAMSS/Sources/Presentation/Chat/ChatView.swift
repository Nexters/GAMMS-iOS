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
    @SwiftUI.Environment(\.dismiss) private var dismiss
    @State private var keyboardHeight: CGFloat = 0

    private let keyboardWillChange = NotificationCenter.default.publisher(
        for: UIResponder.keyboardWillChangeFrameNotification
    )

    init(viewModel: ChatViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// ScrollView 콘텐츠(LazyVStack)에 적용하는 좌우 패딩. `maxBubbleWidth` 계산에 쓰는
    /// containerPadding이 아래 `.padding(containerPadding)`과 같은 값을 참조하도록 상수 하나로
    /// 묶어서, 패딩을 바꿀 때 폭 계산이 따로 놀지 않게 한다.
    private let containerPadding = Spacing.spacing300

    var body: some View {
        ZStack {
            chatContent

            if viewModel.isEndConfirmationPresented {
                ModalContainerView(isPresented: $viewModel.isEndConfirmationPresented) {
                    ModalContentView(
                        title: "대화를 종료하고 감정 기록을 생성할게요",
                        subtitle: "감정 기록 생성 시 대화는 종료되며,\n더 이상 대화를 이어갈 수 없어요.",
                        actions: [
                            .init(title: "뒤로가기", style: .secondary, action: {
                                viewModel.isEndConfirmationPresented = false
                            }),
                            .init(title: "기록 생성하기", style: .primary, action: {
                                viewModel.isEndConfirmationPresented = false
                                Task { await viewModel.confirmEndConversation() }
                            })
                        ]
                    )
                }
            }
        }
    }

    private var chatContent: some View {
        VStack(spacing: 0) {
            header

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
                                        containerPadding: containerPadding * 2
                                    )
                                )
                                .id(message.id)
                                .onLongPressGesture {
                                    if viewModel.startReply(to: message) {
                                        isInputFocused = true
                                    }
                                }
                            }

                            if let pendingUserMessage = viewModel.pendingUserMessage {
                                MessageBubbleView(
                                    pendingUserMessage: pendingUserMessage,
                                    maxWidth: MessageBubbleLayout.maxBubbleWidth(
                                        availableWidth: geometry.size.width,
                                        containerPadding: containerPadding * 2
                                    )
                                )
                                .id(PendingUserMessage.scrollAnchorID)
                            }

                            Color.clear
                                .frame(height: 0)
                                .onAppear { viewModel.markAtBottom(true) }
                                .onDisappear { viewModel.markAtBottom(false) }
                        }
                        .padding(containerPadding)
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded { isInputFocused = false }
                    )
                    .onChange(of: viewModel.messages) { _, newValue in
                        if let last = newValue.last, viewModel.handleNewLastMessage(last) {
                            scrollToBottom(proxy)
                        }
                    }
                    .onChange(of: viewModel.pendingUserMessage) { _, _ in
                        scrollToBottom(proxy)
                    }
                    .onReceive(keyboardWillChange) { notification in
                        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                        let newHeight = max(0, UIScreen.main.bounds.height - frame.origin.y)
                        guard newHeight != keyboardHeight else { return }
                        keyboardHeight = newHeight
                        if viewModel.isAtBottom {
                            let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
                            scrollToBottom(proxy, animation: .easeInOut(duration: duration))
                        }
                    }
                    .onChange(of: viewModel.replyTarget) { _, _ in
                        if viewModel.isAtBottom {
                            scrollToBottom(proxy)
                        }
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        VStack(spacing: 0) {
                            bottomIndicator(proxy: proxy)

                            ChatComposerView(
                                text: $viewModel.input,
                                isSendDisabled: viewModel.isSendDisabled,
                                replyTargetLabel: viewModel.replyTarget.flatMap { QuotedReplyHeader.label(forQuotedSender: $0.sender) },
                                replyTargetContent: viewModel.replyTarget?.content,
                                onCancelReply: { viewModel.cancelReply() },
                                isDisabled: viewModel.isConversationEnded,
                                onSend: { Task { await viewModel.send() } },
                                onTextChange: { viewModel.updateInput($0) },
                                isFocused: $isInputFocused
                            )
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
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
            if viewModel.isCardCreationFailureAlert {
                Button("다시 시도") { Task { await viewModel.retryCreateCard() } }
            }
            Button("확인", role: .cancel) {}
        }
        .fullScreenCover(item: Binding(
            get: { viewModel.createdCard },
            set: { if $0 == nil { viewModel.dismissCard() } }
        )) { card in
            CardResultView(
                card: card,
                viewModel: CardResultViewModel(),
                onComplete: {
                    viewModel.dismissCard()
                    
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            )
            .presentationBackground(.clear)
        }
    }

    /// 커스텀 상단 헤더: 뒤로가기 + 대화방 생성 날짜 + 우측 버튼 2개(종료, 자리만 미리 만든 placeholder).
    /// 시스템 네비게이션 바는 `.toolbar(.hidden, for: .navigationBar)`로 숨기고 이 헤더가 대신한다.
    private var header: some View {
        ZStack {
            Text(headerDateText)
                .typography(.subtitle3)
                .foregroundStyle(Color.colorGray950)

            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.colorGray950)
                }

                Spacer()

                HStack(spacing: Spacing.spacing300) {
                    Button(action: { viewModel.requestEndConversation() }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(Color.colorGray950)
                    }
                    .disabled(!viewModel.canEndConversation)
                    .accessibilityLabel("대화 종료")

                    // 다음 이터레이션에서 동작을 채울 자리만 미리 만든 버튼. 아이콘은 확정 전.
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.colorGray950)
                    }
                    .accessibilityLabel("더보기")
                }
            }
        }
        .padding(.horizontal, Spacing.spacing400)
        .padding(.vertical, Spacing.spacing400)
        .background(Color.colorWhite)
    }

    /// 대화방이 생성된 날짜(yy.MM.dd). 첫 메시지의 시각을 기준으로 삼는다 — 대화방 생성 시점과
    /// 사실상 같고, 별도로 conversationId를 다시 조회하지 않아도 이미 로드된 messages에서 구할 수
    /// 있다. 메시지가 아직 로드되기 전(화면 진입 직후 아주 짧은 순간)에는 빈 문자열을 보여준다.
    private var headerDateText: String {
        guard let firstMessageDate = viewModel.messages.first?.createdAt else { return "" }
        return ConversationListDateHeaderFormatter.string(from: firstMessageDate)
    }

    /// 확정된 메시지 목록의 마지막 항목, 없으면 전송 중인 낙관적 메시지를 기준으로 맨 아래로
    /// 스크롤한다. pendingUserMessage가 항상 messages보다 나중에 화면에 그려지므로, 둘 다 있을
    /// 때는 pendingUserMessage 쪽으로 스크롤해야 실제로 맨 아래가 된다.
    @ViewBuilder
    private func bottomIndicator(proxy: ScrollViewProxy) -> some View {
        if let unseen = viewModel.unseenIncomingMessage {
            NewMessageToastView(message: unseen) {
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(unseen.id, anchor: .bottom)
                }
            }
        } else if !viewModel.isAtBottom {
            HStack {
                Spacer()
                ScrollDownButtonView { scrollToBottom(proxy) }
                    .padding(.trailing, Spacing.spacing300)
                    .padding(.bottom, Spacing.spacing100)
            }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animation: Animation = .easeOut(duration: 0.2)) {
        withAnimation(animation) {
            if viewModel.pendingUserMessage != nil {
                proxy.scrollTo(PendingUserMessage.scrollAnchorID, anchor: .bottom)
            } else if let lastId = viewModel.messages.last?.id {
                proxy.scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}
