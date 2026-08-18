//
//  ConversationListView.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import SwiftUI

enum ConversationMode {
    case normal
    case delete
}

struct ConversationListView: View {
    @StateObject private var viewModel: ConversationListViewModel
    
    init(viewModel: ConversationListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ConversationListHeaderView(currentMode: viewModel.currentMode, onTappedBackButton: {
                    viewModel.updateMode(.normal)
                }, onTappedSearchButton: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.startSearching()
                    }
                })
                .frame(height: 64)
                
                if viewModel.isSearching {
                    ConversationSearchView(onTappedCancelButton: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.stopSearching()
                        }
                    }, onTappedSearchButton: {
                        Task {
                            await viewModel.searchText()
                        }
                    }, editingText: $viewModel.editedText)
                    .frame(height: 42)
                    .transition(
                        .move(edge: .top)
                        .combined(with: .opacity)
                    )
                }
                
                dateHeader.padding(.vertical, Spacing.spacing150)
                
                if !viewModel.isLoading && viewModel.displayedConversations.isEmpty {
                    ConversationListEmptyView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.spacing100) {
                            ForEach(viewModel.displayedConversations) { conversation in
                                switch viewModel.currentMode {
                                case .normal:
                                    NavigationLink(value: conversation) {
                                        ConversationRowView(
                                            currentMode: viewModel.currentMode,
                                            conversation: conversation,
                                            isSelected: false
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                case .delete:
                                    Button {
                                        viewModel.selectConversation(id: conversation.id)
                                    } label: {
                                        ConversationRowView(
                                            currentMode: viewModel.currentMode,
                                            conversation: conversation,
                                            isSelected: viewModel.isSelected(
                                                id: conversation.id
                                            )
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    Spacer()
                    if viewModel.currentMode == .delete {
                        Button {
                            Task {
                                await viewModel.deleteConversations()
                            }
                        } label: {
                            Text("삭제하기")
                                .typography(.body3Medium)
                                .foregroundStyle(
                                    viewModel.isDeleteButtonEnabled
                                    ? Color.colorWhite
                                    : Color.colorGray300
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    viewModel.isDeleteButtonEnabled
                                    ? Color.colorRed
                                    : Color.colorGray075
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                        }
                        .padding(.bottom, 10)
                        .disabled(!viewModel.isDeleteButtonEnabled)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, Spacing.spacing400)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ConversationSummary.self) { conversation in
                ChatView(
                    viewModel: ChatViewModel(
                        sendMessageUseCase: SendMessageUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        getMessagesUseCase: GetMessagesUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        endConversationUseCase: EndConversationUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        createCardUseCase: CreateCardUseCase(cardRepository: DefaultCardRepository(networkManager: NetworkManager.shared)),
                        getTokenUsageUseCase: GetTokenUsageUseCase(memberRepository: DefaultMemberRepository(networkManager: NetworkManager.shared, tokenStorage: .shared)),
                        updateConversationTitleUseCase: UpdateConversationTitleUseCase(conversationRepository: DefaultConversationRepository(networkManager: NetworkManager.shared)),
                        summaryStore: LazyConversationSummaryStore(),
                        conversationId: conversation.id
                    )
                )
                .toolbar(.hidden, for: .tabBar)
            }
        }
        .task {
            await viewModel.load()
        }
        .alert(viewModel.alertMessage ?? "", isPresented: Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        }
    }
    
    /// 오늘 날짜를 표시만 한다 — 목록이 "미완료 대화방"(fetchIncompleteChats) 기준이라 실제로는
    /// 여러 날짜에 걸친 대화가 섞여 있을 수 있지만, 이 헤더는 조회 조건과 무관하게 항상 오늘 날짜 보여줌.
    private var dateHeader: some View {
        HStack {
            Text(ConversationListDateHeaderFormatter.string(from: Date()))
                .typography(.body5Regular)
                .foregroundStyle(Color.colorGray950)
            
            Spacer()
            
            Button {
                viewModel.updateMode(.delete)
            } label: {
                Text("삭제하기")
                    .typography(.body5Regular)
                    .foregroundStyle(Color.colorGray500)
            }
        }
    }
}
