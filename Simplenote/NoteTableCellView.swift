import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class NoteTableCellView: NSTableCellView {

    /// TextField: Title
    ///
    @IBOutlet private var titleTextField: NSTextField!

    /// TextField: Body
    ///
    @IBOutlet private var bodyTextField: NSTextField!

    /// LeftImage: Pinned Indicator
    ///
    @IBOutlet private var leftImageView: NSImageView!

    /// RightImage: Shared Indicator
    ///
    @IBOutlet private var rightImageView: NSImageView!

    /// Indicates if the receiver displays the pinned indicator
    ///
    var displaysPinnedIndicator: Bool {
        get {
            !leftImageView.isHidden
        }
        set {
            leftImageView.isHidden = !newValue
        }
    }

    /// Indicates if the receiver displays the shared indicator
    ///
    var displaysSharedIndicator: Bool {
        get {
            !rightImageView.isHidden
        }
        set {
            rightImageView.isHidden = !newValue
        }
    }

    /// Note's Title String
    ///
    var titleString: String {
        get {
            titleTextField.stringValue
        }
        set {
            titleTextField.stringValue = newValue
        }
    }

    /// Note's Body String
    ///
    var bodyString: String {
        get {
            bodyTextField.stringValue
        }
        set {
            bodyTextField.stringValue = newValue
        }
    }


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTitleField()
        setupBodyField()
        setupLeftImage()
        setupRightImage()
    }
}


// MARK: - Interface Initialization
//
private extension NoteTableCellView {

    func setupTitleField() {
        titleTextField.maximumNumberOfLines = Metrics.maximumNumberOfTitleLines
        titleTextField.textColor = .simplenoteTextColor
    }

    func setupBodyField() {
        bodyTextField.maximumNumberOfLines = Metrics.maximumNumberOfBodyLines
        bodyTextField.textColor = .simplenoteSecondaryTextColor
    }

    func setupLeftImage() {
        // We *don't wanna use* `imageView.contentTintColor` since on highlight it's automatically changing the color!
        let image = NSImage(named: .pin)
        leftImageView.image = image?.tinted(with: .simplenoteActionButtonTintColor)
    }

    func setupRightImage() {
        let image = NSImage(named: .shared)
        rightImageView.image = image?.tinted(with: .simplenoteSecondaryTextColor)
    }
}


// MARK: - Metrics!
//
private enum Metrics {
    static let maximumNumberOfTitleLines = 1
    static let maximumNumberOfBodyLines = 2
}
