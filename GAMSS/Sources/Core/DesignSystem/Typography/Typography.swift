import CoreGraphics

enum Typography: CaseIterable, Hashable {
    case display1, display2
    case title1, title2, title3, title4, title5
    case subtitle1, subtitle2, subtitle3, subtitle4
    case body1Medium, body2Medium, body3Medium, body4Medium, body5Medium, body6Medium
    case body1Regular, body2Regular, body3Regular, body4Regular, body5Regular, body6Regular
    case paragraph1, paragraph2, paragraph3
    case caption1, caption2, caption3, caption4

    struct Metrics {
        let fontSize: CGFloat
        let letterSpacing: CGFloat
        let lineHeight: CGFloat
        let weight: FontWeight

        var lineSpacing: CGFloat {
            lineHeight - fontSize
        }
    }

    var metrics: Metrics {
        switch self {
        case .display1: Metrics(fontSize: 48, letterSpacing: -0.4, lineHeight: 56, weight: .bold)
        case .display2: Metrics(fontSize: 36, letterSpacing: -0.2, lineHeight: 40, weight: .bold)
        case .title1: Metrics(fontSize: 28, letterSpacing: -0.2, lineHeight: 32, weight: .bold)
        case .title2: Metrics(fontSize: 24, letterSpacing: -0.15, lineHeight: 28, weight: .bold)
        case .title3: Metrics(fontSize: 20, letterSpacing: -0.1, lineHeight: 24, weight: .bold)
        case .title4: Metrics(fontSize: 18, letterSpacing: -0.1, lineHeight: 24, weight: .bold)
        case .title5: Metrics(fontSize: 16, letterSpacing: -0.1, lineHeight: 20, weight: .bold)
        case .subtitle1: Metrics(fontSize: 20, letterSpacing: -0.1, lineHeight: 28, weight: .semiBold)
        case .subtitle2: Metrics(fontSize: 18, letterSpacing: -0.1, lineHeight: 24, weight: .semiBold)
        case .subtitle3: Metrics(fontSize: 16, letterSpacing: -0.1, lineHeight: 24, weight: .semiBold)
        case .subtitle4: Metrics(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .semiBold)
        case .body1Medium: Metrics(fontSize: 20, letterSpacing: -0.1, lineHeight: 32, weight: .medium)
        case .body2Medium: Metrics(fontSize: 18, letterSpacing: -0.1, lineHeight: 28, weight: .medium)
        case .body3Medium: Metrics(fontSize: 16, letterSpacing: -0.1, lineHeight: 24, weight: .medium)
        case .body4Medium: Metrics(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .medium)
        case .body5Medium: Metrics(fontSize: 12, letterSpacing: -0.1, lineHeight: 18, weight: .medium)
        case .body6Medium: Metrics(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .medium)
        case .body1Regular: Metrics(fontSize: 20, letterSpacing: -0.1, lineHeight: 32, weight: .regular)
        case .body2Regular: Metrics(fontSize: 18, letterSpacing: -0.1, lineHeight: 28, weight: .regular)
        case .body3Regular: Metrics(fontSize: 16, letterSpacing: -0.1, lineHeight: 24, weight: .regular)
        case .body4Regular: Metrics(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .regular)
        case .body5Regular: Metrics(fontSize: 12, letterSpacing: -0.1, lineHeight: 18, weight: .regular)
        case .body6Regular: Metrics(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .regular)
        case .paragraph1: Metrics(fontSize: 16, letterSpacing: -0.1, lineHeight: 32, weight: .regular)
        case .paragraph2: Metrics(fontSize: 14, letterSpacing: -0.1, lineHeight: 28, weight: .regular)
        case .paragraph3: Metrics(fontSize: 12, letterSpacing: -0.1, lineHeight: 24, weight: .regular)
        case .caption1: Metrics(fontSize: 14, letterSpacing: -0.1, lineHeight: 20, weight: .medium)
        case .caption2: Metrics(fontSize: 12, letterSpacing: -0.1, lineHeight: 18, weight: .medium)
        case .caption3: Metrics(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .medium)
        case .caption4: Metrics(fontSize: 10, letterSpacing: -0.1, lineHeight: 14, weight: .regular)
        }
    }
}
