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

    /// Wraps up access around the SortMode Label
    ///
    var sortModeDescription: String {
        get {
            sortModeLabel.stringValue
        }
        set {
            sortModeLabel.stringValue = newValue
        }
    }

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
