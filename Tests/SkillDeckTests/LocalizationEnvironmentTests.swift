import SwiftUI
import XCTest

@testable import SkillDeck

final class LocalizationEnvironmentTests: XCTestCase {

    func testDefaultLocalizationBundle_isSkillDeckResourceBundle() {
        let values = EnvironmentValues()
        XCTAssertEqual(values.localizationBundle.bundleURL, SkillDeckResources.bundle.bundleURL)
    }
}
