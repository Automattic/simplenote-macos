//
//  SPTextAttachment.swift
//  Simplenote
//  Used in the note editor to distinguish if a checklist item is ticked or not.
//

import Foundation

@objcMembers class SPTextAttachment: NSTextAttachment {
    private var checked = false
    var attachmentColor: NSColor?
    
    @objc public convenience init(color: NSColor) {
        self.init()
        
        attachmentColor = color
    }
    
    var isChecked: Bool {
        get {
            return checked
        }
        set(isChecked) {
            checked = isChecked
            let name = checked ? "icon_task_checked" : "icon_task_unchecked"
            guard let asset = NSImage(named: name)?.colorized(with: attachmentColor) else {
                fatalError()
            }

            if #available(macOS 10.15, *) {
                image = asset
                return
            }

            // macOS < 10.15 inverts the NSTextAttachment.image when drawn. So cool.
            // References:
            //  -   https://stackoverflow.com/questions/49649553/the-image-of-nstextattachment-is-flipped?noredirect=1&lq=1
            //  -   https://github.com/Automattic/simplenote-macos/pull/403
            //
            image = NSImage(size: asset.size, flipped: true) { rect in
                asset.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1.0)
                return true
            }
        }
    }
}
