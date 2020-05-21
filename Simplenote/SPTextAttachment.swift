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

    /// This class relies on TextKit to calculate proper sizing and metrics, so that its image matches characters onScreen. However: in some scenarios, such as "Usage within NSTextField" (Notes List),
    /// the LayoutManager is not always initialized / nor accessible.
    ///
    /// For this reason, we're providing an Override mechanism. Plus: Because of ObjC Interop, it must not be optional (otherwise it won't bridge).
    ///
    var overrideDynamicBounds: NSRect = .zero


    /// Convenience Initializer
    ///
    ///     - tintColor: Text Attachment's Tint Color
    ///
    convenience init(tintColor: NSColor) {
        self.init()

        self.tintColor = tintColor
        refreshImage()
    }
}


// MARK: - Private Methods
//
private extension SPTextAttachment {

    func refreshImage() {
        guard let tintColor = tintColor else {
            return
        }

        let state: NSImage.Name = isChecked ? .taskChecked : .taskUnchecked
        let image = NSImage(named: state)?.tinted(with: tintColor)

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
