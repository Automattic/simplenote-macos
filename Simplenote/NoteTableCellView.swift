import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class NoteTableCellView: NSTableCellView {

    ///
    ///
    @IBOutlet private var titleTextField: NSTextField!

    ///
    ///
    @IBOutlet private var bodyTextField: NSTextField!

    ///
    ///
    @IBOutlet private var leftImageView: NSImageView!

    ///
    ///
    @IBOutlet private var rightImageView: NSImageView!

    ///
    ///
    var displaysPinnedIndicator: Bool {
        get {
            !leftImageView.isHidden
        }
        set {
            leftImageView.isHidden = !newValue
        }
    }

    ///
    ///
    var displaysSharedIndicator: Bool {
        get {
            !rightImageView.isHidden
        }
        set {
            rightImageView.isHidden = !newValue
        }
    }
}


// MARK: - Metrics!
//
private enum Metrics {
    static let maximumNumberOfTitleLines = 1
    static let maximumNumberOfBodyLines = 2
}
