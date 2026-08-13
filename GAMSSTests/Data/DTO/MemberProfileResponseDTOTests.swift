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

    /// 회귀 테스트: 가입 직후 등 닉네임을 아직 설정하지 않은 사용자는 서버가 name/nickname을
    /// null로 내려준다(실기기 확인함, status/createdAt 등 이 DTO에 없는 필드도 함께 옴 —
    /// Decodable은 모르는 키를 무시하므로 문제 없음). 이 필드들이 non-optional이면 디코딩
    /// 자체가 실패해서 홈 화면 진입 시 "사용자 정보를 불러오지 못했어요" 에러가 떴었다.
    func test_decode_withNullNameAndNickname_succeedsAndMapsToNilUser() throws {
        let json = """
        {"id":3,"email":"a@example.com","name":null,"nickname":null,"status":"ACTIVE","createdAt":"2026-08-01T04:08:46.042194Z"}
        """
        let dto = try JSONDecoder().decode(MemberProfileResponseDTO.self, from: Data(json.utf8))

        let user = dto.toDomain()
        XCTAssertEqual(user.id, 3)
        XCTAssertNil(user.name)
        XCTAssertNil(user.nickname)
    }
}
