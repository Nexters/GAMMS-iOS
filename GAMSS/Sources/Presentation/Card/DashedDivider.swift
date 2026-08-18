//
//  DashedDivider.swift
//  GAMSS
//
//  Created by cchanmi on 8/17/26.
//

import SwiftUI

struct DashedDivider: View {
    var body: some View {
        DashedLine()
            .stroke(Color.colorGray950, style: StrokeStyle(lineWidth: 1.3, dash: [5]))
            .frame(height: 1)
    }
}

private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
