//
//  SupportAgency.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

struct SupportAgency: Equatable, Identifiable {
    let id: String
    let name: String
    let description: String
    let phoneNumber: String?
    let url: String?
    let priority: Int
    let isEmergency: Bool
}
