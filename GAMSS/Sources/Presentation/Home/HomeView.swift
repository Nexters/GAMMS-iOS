//
//  HomeView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: Spacing.spacing500) {
                header

                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    Text("OO님 어서오세요")
                        .typography(.title3)
                        .foregroundStyle(Color.colorGray950)
                    Text("마음 쌓아둔 이야기가 있다면 말씀해보세요.")
                        .typography(.body3Regular)
                        .foregroundStyle(Color.colorGray500)
                }

                messageBox

                submitButton

                Spacer()
            }
            .padding(Spacing.spacing400)
            .navigationBarHidden(true)
            .navigationDestination(item: $viewModel.createdConversationId) { conversationId in
                ChatView(
                    viewModel: ChatViewModel(
                        sendMessageUseCase: SendMessageUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        getMessagesUseCase: GetMessagesUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        summaryStore: LazyConversationSummaryStore()
                    ),
                    conversationId: conversationId
                )
                .toolbar(.hidden, for: .tabBar)
            }
        }
        .alert(viewModel.toastMessage ?? "", isPresented: Binding(
            get: { viewModel.toastMessage != nil },
            set: { if !$0 { viewModel.toastMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack {
            Text("GAMSS")
                .typography(.subtitle3)
                .foregroundStyle(Color.colorGray950)
                .padding(.horizontal, Spacing.spacing300)
                .padding(.vertical, Spacing.spacing100)
                .background(Color.colorGray050)
                .clipShape(Capsule())

            Spacer()

            Image(systemName: "gearshape")
                .foregroundStyle(Color.colorGray500)
        }
    }

    private var messageBox: some View {
        VStack(alignment: .trailing, spacing: Spacing.spacing100) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: Radius.radius300)
                    .fill(Color.colorGray025)

                if viewModel.input.isEmpty {
                    Text("임금님 귀는 당나귀 귀")
                        .typography(.body3Regular)
                        .foregroundStyle(Color.colorGray400)
                        .padding(.horizontal, Spacing.spacing300)
                        .padding(.vertical, Spacing.spacing300)
                }

                TextEditor(text: $viewModel.input)
                    .typography(.body3Regular)
                    .foregroundStyle(Color.colorGray950)
                    .scrollContentBackground(.hidden)
                    .padding(Spacing.spacing200)
                    .onChange(of: viewModel.input) { _, newValue in
                        if newValue.count > ConversationSummaryPolicy.maxMessageLength {
                            viewModel.input = String(newValue.prefix(ConversationSummaryPolicy.maxMessageLength))
                        }
                    }
            }
            .frame(height: 220)

            Text("\(viewModel.input.count)/\(ConversationSummaryPolicy.maxMessageLength)")
                .typography(.caption2)
                .foregroundStyle(Color.colorGray400)
        }
    }

    private var submitButton: some View {
        Button {
            Task { await viewModel.send() }
        } label: {
            Text("쪽지 보내기")
                .typography(.subtitle3)
                .foregroundStyle(Color.colorWhite)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.spacing300)
        }
        .background(Color.colorGray950)
        .clipShape(RoundedRectangle(cornerRadius: Radius.radius200))
        .disabled(viewModel.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSending)
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            sendMessageUseCase: SendMessageUseCase(
                conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)
            )
        )
    )
}
