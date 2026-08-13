//
//  MemberProfileResponseDTOTests.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import XCTest
@testable import GAMSS

final class MemberProfileResponseDTOTests: XCTestCase {
    func test_toDomain_mapsAllFieldsToUser() {
        let dto = MemberProfileResponseDTO(id: 1, email: "test@example.com", name: "테스트", nickname: "햄스터")

        let user = dto.toDomain()

        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.name, "테스트")
        XCTAssertEqual(user.nickname, "햄스터")
    }

    func test_decode_fromServerShapedJSON_succeeds() throws {
        let json = """
        {"id":1,"email":"test@example.com","name":"테스트","nickname":"햄스터"}
        """
        let dto = try JSONDecoder().decode(MemberProfileResponseDTO.self, from: Data(json.utf8))

        XCTAssertEqual(dto.toDomain().nickname, "햄스터")
    }
}
