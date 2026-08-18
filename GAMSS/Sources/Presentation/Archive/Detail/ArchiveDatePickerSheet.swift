//
//  ArchiveDatePickerSheet.swift
//  GAMSS
//
//  Created by 이건준 on 8/18/26.
//

import SwiftUI

struct ArchiveDatePickerSheet: View {
    @SwiftUI.Environment(\.dismiss) private var dismiss

    let selectedMonth: Date
    let onSelect: (Date) -> Void

    @State private var draftYear: Int
    @State private var draftMonth: Int

    init(selectedMonth: Date, onSelect: @escaping (Date) -> Void) {
        self.selectedMonth = selectedMonth
        self.onSelect = onSelect

        let calendar = Calendar.current
        _draftYear = State(initialValue: calendar.component(.year, from: selectedMonth))
        _draftMonth = State(initialValue: calendar.component(.month, from: selectedMonth))
    }

    private var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear - 10)...currentYear)
    }

    var body: some View {
        VStack(spacing: 0) {
            closeButton
                .padding(.horizontal, 18)
                .padding(.top, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing200)

            wheelPicker
                .padding(.horizontal, 18)

            Spacer(minLength: Spacing.spacing300)

            confirmButton
                .padding(.horizontal, 18)
                .padding(.bottom, Spacing.spacing500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.colorWhite)
        .presentationDetents([.height(360)])
        .presentationDragIndicator(.hidden)
    }

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.colorGray500)
                    .frame(width: 24, height: 24)
            }
        }
    }

    private var wheelPicker: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.72)
                .fill(Color.colorGray075)
                .frame(height: 44)
                .padding(.horizontal, Spacing.spacing100)

            HStack(spacing: 0) {
                Picker("년", selection: $draftYear) {
                    ForEach(years, id: \.self) { year in
                        Text(verbatim: "\(year)년")
                            .foregroundStyle(Color.colorGray900)
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("월", selection: $draftMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(verbatim: "\(month)월")
                            .foregroundStyle(Color.colorGray900)
                            .tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 216)
    }

    private var confirmButton: some View {
        Button {
            onSelect(makeMonthDate(year: draftYear, month: draftMonth))
            dismiss()
        } label: {
            Text("선택하기")
                .typography(.title5)
                .foregroundStyle(Color.colorWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .background(Color.colorGray900)
        .clipShape(RoundedRectangle(cornerRadius: Radius.radius200))
    }

    private func makeMonthDate(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? selectedMonth
    }
}
