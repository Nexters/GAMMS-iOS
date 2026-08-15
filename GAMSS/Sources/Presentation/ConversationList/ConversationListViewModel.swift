//
//  ConversationListViewModel.swift
//  GAMSS
//
//  Created by cchanmi on 8/8/26.
//

import Combine
import Foundation

@MainActor
final class ConversationListViewModel: ObservableObject {
    @Published private var conversations: [ConversationSummary] = []
    @Published private var searchResults: [ConversationSummary] = []
    var displayedConversations: [ConversationSummary] {
        isSearchExecuted
            ? searchResults
            : conversations
    }
    
    @Published private(set) var currentMode: ConversationMode = .normal
    @Published private(set) var isLoading = false
    @Published var alertMessage: String?
    @Published var editedText: String = ""
    @Published var isSearching: Bool = false
    @Published private(set) var isSearchExecuted = false
    
    @Published private var selectedConversations = Set<Int>()
    var isDeleteButtonEnabled: Bool {
        !selectedConversations.isEmpty
    }
    
    private let getIncompleteConversationsUseCase: GetIncompleteConversationsUseCase
    private let deleteConversationsUseCase: DeleteConversationsUseCase
    private let searchConversationUseCase: SearchConversationUseCase
    
    init(getIncompleteConversationsUseCase: GetIncompleteConversationsUseCase, deleteConversationsUseCase: DeleteConversationsUseCase, searchConversationUseCase: SearchConversationUseCase) {
        self.getIncompleteConversationsUseCase = getIncompleteConversationsUseCase
        self.deleteConversationsUseCase = deleteConversationsUseCase
        self.searchConversationUseCase = searchConversationUseCase
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            conversations = try await getIncompleteConversationsUseCase.execute()
        } catch {
            alertMessage = "채팅방 목록을 불러오지 못했어요"
        }
    }
    
    func isSelected(id: Int) -> Bool {
        selectedConversations.contains(id)
    }
    
    func selectConversation(id: Int) {
        if isSelected(id: id) {
            selectedConversations.remove(id)
        } else {
            selectedConversations.insert(id)
        }
    }
    
    func deleteConversations() async {
        let selectedConversationList = Array(selectedConversations)
        do {
            try await deleteConversationsUseCase.execute(
                conversationIDs: selectedConversationList
            )
            
            conversations.removeAll { conversation in
                selectedConversations.contains(conversation.id)
            }
            
            searchResults.removeAll { conversation in
                selectedConversations.contains(conversation.id)
            }
            
            selectedConversations.removeAll()
        } catch {
            alertMessage = "채팅방을 삭제하지 못했어요"
        }
    }
    
    func updateMode(_ updatedMode: ConversationMode) {
        currentMode = updatedMode
        
        if updatedMode == .normal {
            selectedConversations.removeAll()
        }
    }
    
    func startSearching() {
        isSearching = true
        isSearchExecuted = false
    }
    
    func stopSearching() {
        isSearching = false
        isSearchExecuted = false
        editedText = ""
        searchResults.removeAll()
    }
    
    func searchText() async {
        let query = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            searchResults = try await searchConversationUseCase.execute(query)
            isSearchExecuted = true
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}
