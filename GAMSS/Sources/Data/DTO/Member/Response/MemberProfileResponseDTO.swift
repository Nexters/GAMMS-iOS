//
//  MemberProfileResponseDTO.swift
//  GAMSS
//
//  Created by cchanmi on 8/13/26.
//

import Foundation

struct MemberProfileResponseDTO: Decodable {
    let id: Int
    let email: String
    // 가입 직후 등 이름/닉네임을 아직 설정하지 않은 사용자는 서버가 null로 내려준다
    // (실기기 확인함) — 비-optional로 받으면 그 사용자만 디코딩이 실패해서 홈 화면 진입 시
    // "사용자 정보를 불러오지 못했어요" 에러가 뜬다.
    let name: String?
    let nickname: String?

    func toDomain() -> User {
        User(id: id, email: email, name: name, nickname: nickname)
    }
}
