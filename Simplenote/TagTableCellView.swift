import Foundation
import AppKit


// MARK: - TagTableCellView
//
@objcMembers
class TagTableCellView: NSTableCellView {

    ///
    ///
    private(set) var mouseInside = false

    ///
    ///
    private lazy var trackingArea: NSTrackingArea = {
        NSTrackingArea(rect: .zero, options: [.inVisibleRect, .activeAlways, .mouseEnteredAndExited], owner: self, userInfo: nil)
    }()



    override func prepareForReuse() {
        super.prepareForReuse()
        mouseInside = false
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
