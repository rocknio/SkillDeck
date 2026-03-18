import Foundation
import SwiftUI

private struct LocalizationBundleKey: EnvironmentKey {
    static let defaultValue: Bundle = SkillDeckResources.bundle
}

extension EnvironmentValues {
    var localizationBundle: Bundle {
        get { self[LocalizationBundleKey.self] }
        set { self[LocalizationBundleKey.self] = newValue }
    }
}
