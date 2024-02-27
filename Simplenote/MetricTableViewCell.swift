import Foundation
import AppKit

// MARK: - MetricTableViewCell
//
class MetricTableViewCell: NSTableCellView {

    /// Value's Text Field
    ///
    @IBOutlet private weak var valueTextField: NSTextField?

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

    /// Wraps access to the Value TextField's String Value
    ///
    var value: String? {
        get {
            valueTextField?.stringValue
        }
        set {
            valueTextField?.stringValue = newValue ?? ""
        }
    }

    // MARK: - Overridden Methods

    override func viewWillDraw() {
        super.viewWillDraw()
        refreshStyle()
    }
}

// MARK: - Private API(s)
//
private extension MetricTableViewCell {

    func refreshStyle() {
        textField?.textColor = .simplenoteTextColor
        valueTextField?.textColor = .simplenoteSecondaryTextColor
    }
}
