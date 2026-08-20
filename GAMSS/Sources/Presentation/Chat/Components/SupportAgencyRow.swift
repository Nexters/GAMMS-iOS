//
//  SupportAgencyRow.swift
//  GAMSS
//
//  Created by cchanmi on 8/20/26.
//

import SwiftUI

struct SupportAgencyRow: View {
    let agency: SupportAgency

    private var isEmergency: Bool { agency.isEmergency }

    var body: some View {
        Button(action: open) {
            HStack {
                Text(agency.name)
                    .typography(.subtitle4)
                    .foregroundStyle(isEmergency ? Color.colorWhite : Color.colorGray950)

                Spacer()

                Image(systemName: "phone.fill")
                    .foregroundStyle(isEmergency ? Color.colorWhite : Color.colorGray950)
            }
            .padding(.horizontal, Spacing.spacing300)
            .frame(height: 48)
            .background(isEmergency ? Color.colorRed : Color.colorGray025)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.radius100)
                    .strokeBorder(isEmergency ? Color.clear : Color.colorGray200, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Radius.radius100))
        }
        .buttonStyle(.plain)
    }

    private func open() {
        let urlString: String?
        if let phoneNumber = agency.phoneNumber {
            urlString = "tel:\(phoneNumber)"
        } else {
            urlString = agency.url
        }
        guard let urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    VStack(spacing: 8) {
        SupportAgencyRow(agency: SupportAgency(id: "a", name: "자살예방 상담", description: "", phoneNumber: "109", url: nil, priority: 1, isEmergency: false))
        SupportAgencyRow(agency: SupportAgency(id: "b", name: "긴급 도움이 필요해요", description: "", phoneNumber: "119", url: nil, priority: 5, isEmergency: true))
    }
    .padding()
}
