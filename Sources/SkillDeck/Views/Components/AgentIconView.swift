import SwiftUI

/// AgentIconView renders the appropriate icon for each agent type
///
/// Most agents use SF Symbols via `Image(systemName:)`. Trae uses a custom `TraeIconShape`
/// because its brand icon is not available in SF Symbols.
///
/// This wrapper centralizes the icon-rendering logic so callers don't need to know
/// whether an agent uses SF Symbol or a custom shape — they just embed `AgentIconView`.
///
/// The view inherits the caller's `.foregroundStyle()` and `.font()` modifiers:
/// - For SF Symbol agents: `Image(systemName:)` responds to these modifiers natively
/// - For Trae: the custom shape uses `.fill()` and inherits foreground color from the view hierarchy,
///   and sizes itself via `.aspectRatio(contentMode: .fit)` within the parent's `.frame()`
struct AgentIconView: View {

    let agentType: AgentType

    var body: some View {
        if agentType == .trae {
            // Custom shape for Trae: uses even-odd fill rule (eoFill: true)
            // to correctly cut out the diamond shapes from the rounded rectangle frame.
            // `.aspectRatio(1, contentMode: .fit)` keeps the icon square and fits within
            // whatever `.frame()` the caller provides.
            // The shape inherits `.foregroundStyle()` from the parent view hierarchy,
            // so callers can color it the same way they color SF Symbols.
            TraeIconShape()
                .fill(style: FillStyle(eoFill: true))
                .aspectRatio(1, contentMode: .fit)
        } else {
            // Standard SF Symbol for all other agents
            // SF Symbols automatically inherit `.font()`, `.foregroundStyle()`, etc.
            Image(systemName: agentType.iconName)
        }
    }
}
