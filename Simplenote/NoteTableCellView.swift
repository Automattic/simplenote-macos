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

}


// MARK: - Metrics!
//
private enum Metrics {
    static let maximumNumberOfTitleLines = 1
    static let maximumNumberOfBodyLines = 2
}
