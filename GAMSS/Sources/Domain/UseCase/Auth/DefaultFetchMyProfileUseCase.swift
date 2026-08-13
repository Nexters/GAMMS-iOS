//
//  DefaultFetchMyProfileUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

struct DefaultFetchMyProfileUseCase: FetchMyProfileUseCase {
    private let memberRepository: MemberRepository

    init(memberRepository: MemberRepository) {
        self.memberRepository = memberRepository
    }

    func execute() async throws -> User {
        try await memberRepository.fetchMyProfile()
    }
}
