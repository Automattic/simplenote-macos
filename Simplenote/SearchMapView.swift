import AppKit

// MARK: - SearchMapView
//
@objc
final class SearchMapView: NSView {
    private var positions: [CGFloat] = []

    /// Update with positions of bars. Position is from 0.0 to 1.0
    ///
    func update(with positions: [CGFloat]) {
        self.positions = positions
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        NSColor.simplenoteExcerptHighlightColor.set()
        for position in positions {
            let rect = NSRect(x: 0,
                              y: (bounds.height - bounds.height * position) - Metrics.barHeight / 2,
                              width: bounds.width,
                              height: Metrics.barHeight)
            NSBezierPath.fill(rect)
        }
    }
}

private enum Metrics {
    static let barHeight: CGFloat = 2.0
}
