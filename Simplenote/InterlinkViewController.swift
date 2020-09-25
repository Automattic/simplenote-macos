import Foundation
import AppKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: NSViewController {

    /// Background
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: NSTableView!

    /// Mouse Tracking
    ///
    private lazy var trackingArea = NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)


    // MARK: - Overridden Methdos

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupMouseCursor()
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseExited(with: event)
        NSCursor.pointingHand.set()
    }
}


// MARK: - Setup!
//
private extension InterlinkViewController {

    func setupBackground() {
        backgroundView.fillColor = .simplenoteBackgroundColor
        tableView.backgroundColor = .clear
    }

    func setupMouseCursor() {
        tableView.addCursorRect(tableView.bounds, cursor: .pointingHand)
    }
}


}
}
