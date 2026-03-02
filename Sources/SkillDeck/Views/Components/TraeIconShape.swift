import SwiftUI

/// TraeIconShape draws the Trae (ByteDance AI IDE) brand icon as a SwiftUI Shape
///
/// SwiftUI's `Shape` protocol requires implementing `path(in:)` which returns a `Path` —
/// similar to Android's Canvas.drawPath() or Java2D's GeneralPath.
/// The path data is derived from the official Trae SVG icon (lobehub collection).
///
/// Original SVG viewBox: 0 0 24 24, uses even-odd fill rule.
/// The icon consists of a rounded rectangle frame with two diamond/rhombus shapes inside.
///
/// Usage: Use with `FillStyle(eoFill: true)` to get correct even-odd rendering:
/// ```swift
/// TraeIconShape()
///     .fill(style: FillStyle(eoFill: true))
/// ```
struct TraeIconShape: Shape {

    /// Draws the Trae icon path scaled to fit the given rectangle
    ///
    /// `CGRect` (Core Graphics Rectangle) defines the drawing area.
    /// We normalize the SVG coordinates (0–24) to fit within `rect` using scale factors.
    /// `Path` is SwiftUI's equivalent of SVG <path> — a series of move/line/curve commands.
    func path(in rect: CGRect) -> Path {
        // Scale factors convert from SVG coordinate space (24x24) to the actual view size
        // Similar to Android's Matrix.setScale() or CSS transform: scale()
        let scaleX = rect.width / 24.0
        let scaleY = rect.height / 24.0

        // Helper to convert SVG coordinates to view coordinates
        // CGPoint is a 2D point (x, y), like Java's Point2D.Double
        func p(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: x * scaleX, y: y * scaleY)
        }

        var path = Path()

        // --- Outer rounded rectangle frame ---
        // SVG: M1 4C1 2.34315 2.34315 1 4 1H20C21.6569 1 23 2.34315 23 4V20C23 21.6569 21.6569 23 20 23H4C2.34315 23 1 21.6569 1 20V4Z
        // This draws a rounded rectangle from (1,1) to (23,23) with corner radius ~3
        // moveTo starts at (1,4), then cubic Bézier curves draw the rounded corners
        path.move(to: p(1, 4))
        // Top-left corner: cubic Bézier from (1,4) curving through control points to (4,1)
        path.addCurve(to: p(4, 1), control1: p(1, 2.34315), control2: p(2.34315, 1))
        // Top edge
        path.addLine(to: p(20, 1))
        // Top-right corner
        path.addCurve(to: p(23, 4), control1: p(21.6569, 1), control2: p(23, 2.34315))
        // Right edge
        path.addLine(to: p(23, 20))
        // Bottom-right corner
        path.addCurve(to: p(20, 23), control1: p(23, 21.6569), control2: p(21.6569, 23))
        // Bottom edge
        path.addLine(to: p(4, 23))
        // Bottom-left corner
        path.addCurve(to: p(1, 20), control1: p(2.34315, 23), control2: p(1, 21.6569))
        // Left edge back to start
        path.closeSubpath()

        // --- Upper diamond shape ---
        // SVG: M12.0547 4L7.04688 9.00781L12.0547 14.0156L17.0625 9.00781L12.0547 4Z
        // A diamond/rhombus centered at roughly (12, 9), representing the upper part of the Trae logo
        path.move(to: p(12.0547, 4))
        path.addLine(to: p(7.04688, 9.00781))
        path.addLine(to: p(12.0547, 14.0156))
        path.addLine(to: p(17.0625, 9.00781))
        path.closeSubpath()

        // --- Lower diamond shape ---
        // SVG: M12.0547 10.6953L7.04688 15.7031L12.0547 20.7109L17.0625 15.7031L12.0547 10.6953Z
        // A diamond/rhombus centered at roughly (12, 15.7), representing the lower part of the Trae logo
        path.move(to: p(12.0547, 10.6953))
        path.addLine(to: p(7.04688, 15.7031))
        path.addLine(to: p(12.0547, 20.7109))
        path.addLine(to: p(17.0625, 15.7031))
        path.closeSubpath()

        return path
    }
}
