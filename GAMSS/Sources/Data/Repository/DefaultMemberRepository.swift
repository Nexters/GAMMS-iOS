//
//  DefaultMemberRepository.swift
//  GAMSS
//
//  Created by 이건준 on 8/13/26.
//

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
    }

    func fetchMyProfile() async throws -> User {
        let response = try await networkManager.request(MemberEndpoint.fetchMyProfile, responseType: APIResponse<MemberProfileResponseDTO>.self)
        return response.data.toDomain()
    }
}
