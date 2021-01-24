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

    /// Indicates if the mouse was last seen inside the receiver's bounds
    ///
    private(set) var mouseInside = false


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
        iconImageView.isHidden = true
        nameTextField.isEditable = false
    }

    func refreshStyle() {
        let formatter = TagTextFormatter(maximumLength: SimplenoteConstants.maximumTagLength, disallowSpaces: true)
        let icon = iconImageView.image

        // We *don't wanna use* `imageView.contentTintColor` since on highlight it's automatically changing the tintColor!
        iconImageView.image = icon?.tinted(with: .simplenoteAccessoryTintColor)
        nameTextField.textRegularColor = .simplenoteTextColor

        nameTextField.textEditionColor = .simplenoteTextColor
        nameTextField.formatter = formatter
    }
}
