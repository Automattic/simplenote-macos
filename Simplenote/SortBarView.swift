import Foundation
import AppKit


// MARK: - SortBarView
//
class SortBarView: NSView {

    /// Storyboard Outlets
    ///
    @IBOutlet private var titleLabel: NSTextField!
    @IBOutlet private var sortModeLabel: NSTextField!
    @IBOutlet private var chevronImageView: NSImageView!


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.stringValue = NSLocalizedString("Sort:", comment: "Sortbar Title")
    }

    func refreshStyle() {
        titleLabel.textColor = .simplenoteSecondaryTextColor
        sortModeLabel.textColor = .simplenoteSecondaryTextColor
    }
}
