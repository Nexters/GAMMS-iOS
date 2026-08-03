enum FontWeight: Hashable {
    case regular, medium, semiBold, bold

    private var suffix: String {
        switch self {
        case .regular: "Regular"
        case .medium: "Medium"
        case .semiBold: "SemiBold"
        case .bold: "Bold"
        }
    }

    func postScriptName(family: FontFamily = .pretendard) -> String {
        "\(family.name)-\(suffix)"
    }
}
