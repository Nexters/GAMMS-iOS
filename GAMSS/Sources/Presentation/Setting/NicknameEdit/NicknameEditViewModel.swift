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
    @Published var errorMessage: String?
    
    var isEnabledSaveButton: Bool {
        !editingNickname.isEmpty
    }
    
    init(updateNicknameUseCase: UpdateNicknameUseCase) {
        self.updateNicknameUseCase = updateNicknameUseCase
    }
    
    func updateNickname() async {
        do {
            try await updateNicknameUseCase.execute(editingNickname)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
