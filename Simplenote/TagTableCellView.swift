import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class TagTableCellView: NSTableCellView, TableCellView {

    /// Tracking Areas
    ///
    private lazy var trackingArea = NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)

    /// Indicates if the mouse was last seen inside the receiver's bounds
    ///
    private(set) var mouseInside = false {
        didSet {
            guard oldValue != mouseInside else {
                return
            }

            refreshStyle()
        }
    }

    /// Indicates if the receiver's associated NSTableRowView is *selected*
    ///
    var isSelected = false {
        didSet {
            guard oldValue != isSelected else {
                return
            }

            refreshStyle()
        }
    }


    // MARK: - Overridden Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        refreshStyle()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
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


// MARK: - Styling
//
private extension TagTableCellView {

    func reset() {
        mouseInside = false
        isSelected = false
        imageView?.isHidden = true
        textField?.isEditable = false
    }

    func refreshStyle() {
        let targetAlpha = !isSelected && mouseInside ? AppKitConstants.alpha0_6 : AppKitConstants.alpha1_0
        let targetColor = isSelected ? NSColor.simplenoteTagListSelectedTextColor : .simplenoteTagListRegularTextColor
        imageView?.wantsLayer = true
        imageView?.alphaValue = targetAlpha
        imageView?.image = imageView?.image?.tinted(with: targetColor)

        textField?.wantsLayer = true
        textField?.alphaValue = targetAlpha
        textField?.textColor = targetColor
    }
}
