import Foundation
import AppKit


// MARK: - HeaderTableCellView
//
class HeaderTableCellView: NSTableCellView {

    override func prepareForReuse() {
        super.prepareForReuse()
        textField?.textColor = .simplenoteSecondaryTextColor
    }
}
