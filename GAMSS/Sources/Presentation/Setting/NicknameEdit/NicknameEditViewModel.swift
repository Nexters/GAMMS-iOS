//
//  NicknameEditViewModel.swift
//  GAMSS
//
//  Created by 이건준 on 8/16/26.
//

import Combine
import Foundation

final class NicknameEditViewModel: ObservableObject {
    private let updateNicknameUseCase: UpdateNicknameUseCase
    @Published var editingNickname: String = ""
    
    /// FIXME: - 에러 발생 시 스낵바 처리 필요
    @Published var errorMessage: String?
    
    var isEnabledSaveButton: Bool {
        !editingNickname.isEmpty
    }
    
    init(updateNicknameUseCase: UpdateNicknameUseCase) {
        self.updateNicknameUseCase = updateNicknameUseCase
    }
    
    func updateNickname() async -> Bool {
        do {
            try await updateNicknameUseCase.execute(editingNickname)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
