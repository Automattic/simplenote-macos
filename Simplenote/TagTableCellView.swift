import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class TagTableCellView: NSTableCellView {

    /// Indicates if the mouse was last seen inside the receiver's bounds
    ///
    private(set) var mouseInside = false

    /// Tracking Areas
    ///
    private lazy var trackingArea: NSTrackingArea = {
        NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
    }()


    // MARK: - Overridden Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        applyStyle()
        mouseInside = false
        imageView?.isHidden = false
        textField?.isEditable = false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }

    func applyStyle() {

    }
}


// MARK: - Tracking Areas
//
extension TagTableCellView {

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        guard trackingAreas.contains(trackingArea) == false else {
            return
        }
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        mouseInside = true
        NSCursor.pointingHand.set()
    }

    override func mouseExited(with event: NSEvent) {
        mouseInside = false
        NSCursor.arrow.set()
    }
}
