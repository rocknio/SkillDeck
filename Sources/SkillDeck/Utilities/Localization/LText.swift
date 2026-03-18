import SwiftUI
struct LText: View {
    let key: String

    @Environment(\.localizationBundle) private var localizationBundle

    @Environment(\.locale) private var locale

    var body: some View {
        Text(L10n.string(key, bundle: localizationBundle, locale: locale))
    }
}
