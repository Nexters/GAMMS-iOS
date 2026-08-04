import XCTest
import UIKit
import SwiftUI
@testable import GAMSS

final class Color_GAMSSTests: XCTestCase {
    private struct VariantCase {
        let name: String
        let light: String
        let dark: String
    }

    private let variantCases: [VariantCase] = [
        VariantCase(name: "colorGray025", light: "#FDFEFF", dark: "#1E1F22"),
        VariantCase(name: "colorGray050", light: "#F7F9FB", dark: "#24262B"),
        VariantCase(name: "colorGray075", light: "#EFF2F6", dark: "#2A2D33"),
        VariantCase(name: "colorGray100", light: "#E7ECF1", dark: "#30343B"),
        VariantCase(name: "colorGray200", light: "#DCE0E6", dark: "#3B4048"),
        VariantCase(name: "colorGray300", light: "#C2C7D1", dark: "#4B505B"),
        VariantCase(name: "colorGray400", light: "#AAAFBD", dark: "#676C78"),
        VariantCase(name: "colorGray500", light: "#9094A3", dark: "#8A909C"),
        VariantCase(name: "colorGray600", light: "#797C8B", dark: "#B0B5C0"),
        VariantCase(name: "colorGray700", light: "#5A5D68", dark: "#CDD2DB"),
        VariantCase(name: "colorGray800", light: "#474951", dark: "#E1E5EB"),
        VariantCase(name: "colorGray900", light: "#303136", dark: "#F2F5F8"),
        VariantCase(name: "colorGray950", light: "#1E1F22", dark: "#FCFDFE"),
        VariantCase(name: "colorGreen", light: "#36AF7C", dark: "#3BDB98"),
        VariantCase(name: "colorRed", light: "#EF3535", dark: "#FF4444"),
        VariantCase(name: "colorBlue", light: "#376CE8", dark: "#447CFF"),
    ]

    private let fixedCases: [(name: String, hex: String)] = [
        ("colorWhite", "#FFFFFF"),
        ("colorBlack", "#000000"),
        ("colorPink", "#FF7E9A"),
        ("colorYellow", "#FFD373"),
        ("colorPurple", "#C08CEA"),
        ("colorSkyblue", "#66C3F1"),
        ("colorApricot", "#FB6F56"),
    ]

    func test_variantColorSets_resolveDifferentlyInLightAndDark() throws {
        for testCase in variantCases {
            let uiColor = try XCTUnwrap(UIColor(named: testCase.name), "\(testCase.name) not found in Asset Catalog")
            let light = uiColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            let dark = uiColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
            XCTAssertEqual(light.hexString, testCase.light, "\(testCase.name) light")
            XCTAssertEqual(dark.hexString, testCase.dark, "\(testCase.name) dark")
        }
    }

    func test_fixedColorSets_resolveSameHexRegardlessOfAppearance() throws {
        for testCase in fixedCases {
            let uiColor = try XCTUnwrap(UIColor(named: testCase.name), "\(testCase.name) not found in Asset Catalog")
            let light = uiColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            let dark = uiColor.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
            XCTAssertEqual(light.hexString, testCase.hex, "\(testCase.name) light")
            XCTAssertEqual(dark.hexString, testCase.hex, "\(testCase.name) dark")
        }
    }

    func test_colorGAMSSExtension_exposesAllTokensByFigmaName() {
        XCTAssertEqual(UIColor(Color.colorWhite).hexString, "#FFFFFF")
        XCTAssertEqual(UIColor(Color.colorBlack).hexString, "#000000")
        XCTAssertEqual(UIColor(Color.colorGray500).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).hexString, "#9094A3")
        XCTAssertEqual(UIColor(Color.colorPink).hexString, "#FF7E9A")
        XCTAssertEqual(UIColor(Color.colorRed).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).hexString, "#EF3535")
        XCTAssertEqual(UIColor(Color.colorBlue).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)).hexString, "#376CE8")
    }
}

private extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }
}
