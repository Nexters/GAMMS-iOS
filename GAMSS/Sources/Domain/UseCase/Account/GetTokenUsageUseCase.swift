//
//  GetTokenUsageUseCase.swift
//  GAMSS
//
//  Created by cchanmi on 8/18/26.
//

struct GetTokenUsageUseCase {
    private let memberRepository: MemberRepository

    init(memberRepository: MemberRepository) {
        self.memberRepository = memberRepository
    }

    func execute() async throws -> TokenUsage {
        try await memberRepository.fetchTokenUsage()
    }
}
