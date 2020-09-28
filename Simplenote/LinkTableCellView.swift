import Foundation
import AppKit


// MARK: - LinkTableCellView
//
@objcMembers
class LinkTableCellView: NSTableCellView {

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

    // MARK: - Overridden Methods

    override func viewWillDraw() {
        super.viewWillDraw()
        refreshStyle()
    }
}


// MARK: - Private API(s)
//
private extension LinkTableCellView {

    func refreshStyle() {
        textField?.textColor = .simplenoteTextColor
    }
}
