import AppKit

// MARK: - SearchMapView
//
@objc
final class SearchMapView: NSView {
    private var barViews: [NSView] = []

    /// Update with positions of bars. Position is from 0.0 to 1.0
    ///
    func update(with positions: [CGFloat]) {
        for barView in barViews {
            barView.removeFromSuperview()
        }
        barViews = []
        for position in positions {
            createBarView(with: position)
        }
    }

    private func createBarView(with position: CGFloat) {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.simplenoteExcerptHighlightColor.cgColor

        addSubview(view)

        let verticalCenterConstraint = NSLayoutConstraint(item: view,
                                                          attribute: .centerY,
                                                          relatedBy: .equal,
                                                          toItem: self,
                                                          attribute: .centerY,
                                                          multiplier: position * 2,
                                                          constant: 0.0)
        verticalCenterConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: Metrics.barHeight),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalCenterConstraint
        ])

        barViews.append(view)
    }
}

private enum Metrics {
    static let barHeight: CGFloat = 2.0
}
