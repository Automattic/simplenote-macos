import Foundation
import AppKit


// MARK: - LinkTableCellView
//
@objcMembers
class LinkTableCellView: NSTableCellView {

    /// Workaround: In AppKit, TableView Cell Selection works at the Row level
    ///
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            refreshSelectedState()
        }
    }

    /// Indicates if the receiver's associated NSTableRowView is *selected*
    ///
    private var selected = false {
        didSet {
            guard oldValue != selected else {
                return
            }

            refreshStyle()
        }
    }

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


// MARK: - Selection Workaround
//
private extension LinkTableCellView {

    func refreshSelectedState() {
        guard let row = superview as? NSTableRowView else {
            return
        }

        selected = row.isSelected
    }
}

// MARK: - Private API(s)
//
private extension LinkTableCellView {

    func refreshStyle() {
        textField?.textColor = .simplenoteTextColor
    }
}
