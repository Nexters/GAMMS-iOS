enum FontWeight: Hashable {
    case regular, medium, semiBold, bold

    var postScriptName: String {
        switch self {
        case .regular: "Pretendard-Regular"
        case .medium: "Pretendard-Medium"
        case .semiBold: "Pretendard-SemiBold"
        case .bold: "Pretendard-Bold"
        }
    }
}
