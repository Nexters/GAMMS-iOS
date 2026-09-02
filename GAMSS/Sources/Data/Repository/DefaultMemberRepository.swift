//
//  DefaultMemberRepository.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

import FirebaseAuth
import Foundation

final class DefaultMemberRepository: MemberRepository {
    private let networkManager: NetworkRequesting
    private let tokenStorage: TokenStorage

    init(networkManager: NetworkRequesting, tokenStorage: TokenStorage) {
        self.networkManager = networkManager
        self.tokenStorage = tokenStorage
    }
    
    func deleteMember() async throws {
        _ = try await networkManager.request(MemberEndpoint.deleteAccount, responseType: APIResponse<EmptyResponseDTO>.self)
        try tokenStorage.deleteTokens()
        try? Auth.auth().signOut()
    }

    func fetchMyProfile() async throws -> User {
        let response = try await networkManager.request(MemberEndpoint.fetchMyProfile, responseType: APIResponse<MemberProfileResponseDTO>.self)
        return response.data.toDomain()
    }
    
    func updateNickname(_ nickname: String) async throws -> User {
        let response = try await networkManager.request(MemberEndpoint.updateNickname(.init(nickname: nickname)), responseType: APIResponse<UpdateNicknameResponseDTO>.self)
        return User(
            id: response.data.id,
            email: response.data.email,
            name: response.data.name,
            nickname: response.data.nickname
        )
    }

    func fetchTokenUsage() async throws -> TokenUsage {
        let response = try await networkManager.request(MemberEndpoint.fetchMyTokenUsage, responseType: APIResponse<TokenUsageResponseDTO>.self)
        return response.data.toDomain()
    }
}
