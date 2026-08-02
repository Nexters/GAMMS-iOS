import SwiftUI

struct TypographyModifier: ViewModifier {
    let scale: Typography

    func body(content: Content) -> some View {
        let metrics = scale.metrics
        content
            .font(.custom(metrics.weight.postScriptName, size: metrics.fontSize))
            .tracking(metrics.letterSpacing)
            .lineSpacing(metrics.lineHeight - metrics.fontSize)
    }
}

extension View {
    func typography(_ scale: Typography) -> some View {
        modifier(TypographyModifier(scale: scale))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.spacing200) {
        Text("Display1 안녕하세요").typography(.display1)
        Text("Title1 안녕하세요").typography(.title1)
        Text("Subtitle1 안녕하세요").typography(.subtitle1)
        Text("Body1_Regular 안녕하세요").typography(.body1Regular)
        Text("Caption1 안녕하세요").typography(.caption1)
    }
    .padding(Spacing.spacing300)
}
