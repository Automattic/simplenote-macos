import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class TagTableCellView: NSTableCellView {

    /// Icon rendered on the left hand side
    ///
    @IBOutlet var iconImageView: NSImageView!

    /// We really can't use the default `.textField` property
    ///
    @IBOutlet var nameTextField: SPTextField!

    /// Workaround: In AppKit, TableView Cell Selection works at the Row level
    ///
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            refreshSelectedState()
        }
    }

    /// Indicates if the mouse was last seen inside the receiver's bounds
    ///
    private(set) var mouseInside = false

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

    /// Tracking Areas
    ///
    private lazy var trackingArea = NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }

    override func viewWillDraw() {
        super.viewWillDraw()
        refreshStyle()
    }
}


// MARK: - Tracking Areas
//
extension TagTableCellView {

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if !trackingAreas.contains(trackingArea) {
            addTrackingArea(trackingArea)
        }
    }

    override func mouseEntered(with event: NSEvent) {
        mouseInside = true
    }

    override func mouseExited(with event: NSEvent) {
        mouseInside = false
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .pointingHand)
    }
}


// MARK: - Selection Workaround
//
private extension TagTableCellView {

    func refreshSelectedState() {
        guard let row = superview as? NSTableRowView else {
            return
        }

        selected = row.isSelected
    }
}


// MARK: - Styling
//
private extension TagTableCellView {

    func setupSubviews() {
        iconImageView.wantsLayer = true
        nameTextField.wantsLayer = true
    }

    func reset() {
        mouseInside = false
        selected = false
        iconImageView.isHidden = true
        nameTextField.isEditable = false
    }

    func refreshStyle() {
        let tintColor: NSColor = selected ? .simplenoteSelectedTextColor : .simplenoteTextColor

        iconImageView.tintImage(color: tintColor)
        nameTextField.isSelected = selected
        nameTextField.textRegularColor = .simplenoteTextColor
        nameTextField.textSelectionColor = .simplenoteSelectedTextColor
        nameTextField.textEditionColor = .simplenoteTextColor
    }
}
