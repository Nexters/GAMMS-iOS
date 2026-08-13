//
//  DefaultDeleteMemberUseCase.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

import Foundation

struct DefaultDeleteMemberUseCase: DeleteMemberUseCase {
    private let memberRepository: MemberRepository
    
    init(memberRepository: MemberRepository) {
        self.memberRepository = memberRepository
    }
    
    func execute() async throws {
        _ = try await memberRepository.deleteMember()
    }
}
