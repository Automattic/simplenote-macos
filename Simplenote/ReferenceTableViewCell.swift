import Foundation
import AppKit

// MARK: - ReferenceTableViewCell
//
class ReferenceTableViewCell: NSTableCellView {

    /// Details TextField
    ///
    @IBOutlet private weak var detailsTextField: NSTextField!

    /// Wraps access to the TextField's String Value
    ///
    var title: String? {
        get {
            textField?.stringValue
        }
        set {
            textField?.stringValue = newValue ?? ""
        }
    }

    /// Wraps access to the Details TextField's String Value
    ///
    var details: String? {
        get {
            detailsTextField?.stringValue
        }
        set {
            detailsTextField?.stringValue = newValue ?? ""
        }
    }

    // MARK: - Overridden Methods

    override func viewWillDraw() {
        super.viewWillDraw()
        refreshStyle()
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}

// MARK: - Private API(s)
//
private extension ReferenceTableViewCell {

    func refreshStyle() {
        textField?.textColor = .simplenoteTextColor
        detailsTextField?.textColor = .simplenoteSecondaryTextColor
    }
}
