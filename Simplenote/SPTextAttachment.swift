//
//  SPTextAttachment.swift
//  Simplenote
//  Used in the note editor to distinguish if a checklist item is ticked or not.
//

import Foundation


// MARK: - SPTextAttachment
//
@objcMembers
class SPTextAttachment: NSTextAttachment {

    /// Attachment State
    ///
    private enum State: String {
        case checked = "icon_task_checked"
        case unchecked = "icon_task_unchecked"
    }

    /// Indicates if the Attachment is checked or not. We're keeping this one as Boolean (for now) for ObjC interop purposes
    ///
    var isChecked = false {
        didSet {
            refreshImage()
        }
    }

    /// Attachment Image Tint Color
    ///
    var tintColor: NSColor? {
        didSet {
            refreshImage()
        }
    }

    ///
    /// Note: Why not optional? Because of ObjC Interop. Optionals NSRect won't bridge.
    ///
    var overrideDynamicBounds: NSRect = .zero

    // MARK: - Private Methods

    private func refreshImage() {
        guard let tintColor = tintColor else {
            return
        }

        let state = isChecked ? State.checked : State.unchecked
        let image = NSImage(named: state.rawValue)?.colorized(with: tintColor)
        attachmentCell = SPTextAttachmentCell(imageCell: image)
    }
}


// MARK: - SPTextAttachmentCell
//
class SPTextAttachmentCell: NSTextAttachmentCell {

    /// Parent TextAttachment, if any
    ///
    var parentTextAttachment: SPTextAttachment? {
        return attachment as? SPTextAttachment
    }

    // MARK: - Overridden Methods

    override func cellFrame(for textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
        if let overriddenBounds = parentTextAttachment?.overrideDynamicBounds, overriddenBounds != .zero {
            return overriddenBounds
        }

        guard let image = image, let font = textContainer.layoutManager?.textStorage?.font(at: charIndex) else {
            return super.cellFrame(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        }

        return bounds(image: image, font: font, lineFragment: lineFrag)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        image?.draw(in: cellFrame)

    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
        image?.draw(in: cellFrame)
    }


    // MARK: - Private Methods

    private func bounds(image: NSImage, font: NSFont, lineFragment: NSRect) -> NSRect {
        let ratio = font.pointSize / image.size.height
        let side = max(image.size.width, image.size.height) * ratio
        let paddingY = (lineFragment.height - side) * -0.5

        return CGRect(x: 0, y: paddingY, width: side, height: side)
    }
}
