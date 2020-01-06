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

    /// Attachment Image Tint Color
    ///
    var tintColor: NSColor? {
        didSet {
            refreshImage()
        }
    }

    /// Indicates if the Attachment is checked or not. We're keeping this one as Boolean (for now) for ObjC interop purposes
    ///
    var isChecked = false {
        didSet {
            refreshImage()
        }
    }


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

    // MARK: - Overridden Methods

    override func cellFrame(for textContainer: NSTextContainer, proposedLineFragment lineFrag: NSRect, glyphPosition position: NSPoint, characterIndex charIndex: Int) -> NSRect {
        guard let image = image,
            let storage = textContainer.layoutManager?.textStorage,
            let font = storage.attribute(.font, at: charIndex, effectiveRange: nil) as? NSFont
            else {
                return super.cellFrame(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
        }


        let ratio = font.pointSize / image.size.height
        let side = floor(max(image.size.width, image.size.height) * ratio)
        let paddingY = floor((lineFrag.height - side) * -0.5)

        return CGRect(x: 0, y: paddingY, width: side, height: side)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        image?.draw(in: cellFrame)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?, characterIndex charIndex: Int, layoutManager: NSLayoutManager) {
        image?.draw(in: cellFrame)
    }
}
