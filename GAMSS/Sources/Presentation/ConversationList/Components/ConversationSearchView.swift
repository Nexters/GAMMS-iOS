//
//  ConversationSearchView.swift
//  GAMSS
//
//  Created by 이건준 on 8/15/26.
//

import SwiftUI

struct ConversationSearchView: View {
    var onTappedCancelButton: (() -> Void)?
    var onTappedSearchButton: (() -> Void)?
    @Binding var editingText: String
    
    var body: some View {
        HStack(spacing: 16) {
            TextField(text: $editingText) {
                Text("검색어 입력")
                    .typography(.body4Medium)
                    .foregroundStyle(Color.colorGray400)
            }
            .typography(.body4Medium)
            .foregroundStyle(Color.colorGray950)
            .padding(.vertical, 11)
            .padding(.horizontal, 16)
            .background(Color.colorGray075)
            .submitLabel(.search)
            .onSubmit {
                onTappedSearchButton?()
            }
            
            Button {
                onTappedCancelButton?()
            } label: {
                Text("취소")
                    .typography(.body4Medium)
                    .foregroundStyle(Color.colorGray950)
            }
        }
    }
}
