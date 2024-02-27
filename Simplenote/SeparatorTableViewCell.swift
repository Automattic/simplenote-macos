import Foundation
import AppKit

// MARK: - SeparatorTableViewCell
//
class SeparatorTableViewCell: NSTableCellView {

    /// Draws the main separator
    ///
    @IBOutlet private weak var separatorView: BackgroundView!

    // MARK: - Overridden API(s)

    override func viewWillDraw() {
        super.viewWillDraw()
        separatorView.fillColor = .simplenotePlaceholderTintColor
    }
}
