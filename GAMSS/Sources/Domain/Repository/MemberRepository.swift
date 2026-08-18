//
//  MemberRepository.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

protocol MemberRepository {
    func deleteMember() async throws

    /// 로그인된 사용자의 프로필(닉네임 포함)을 조회한다.
    func fetchMyProfile() async throws -> User
    func updateNickname(_ nickname: String) async throws -> User
    func fetchTokenUsage() async throws -> TokenUsage
}
