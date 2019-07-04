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
            image = NSImage(named: name)?.colorized(with: attachmentColor)
        }
    }
}
