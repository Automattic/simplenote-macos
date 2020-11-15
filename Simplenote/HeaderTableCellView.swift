import Foundation
import AppKit


// MARK: - HeaderTableCellView
//
class HeaderTableCellView: NSTableCellView {

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

    /// Wraps access to the TextField's Text Color
    ///
    var titleColor: NSColor? {
        get {
            textField?.textColor
        }
        set {
            textField?.textColor = newValue
        }
    }
}
