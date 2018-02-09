//
//  SPAboutTextField.swift
//  Simplenote
//
//  An NSTextField that shows a hand pointer on hover 👆
//

import Cocoa

@objc class SPAboutTextField: NSTextField {

    override func resetCursorRects() {
        self.addCursorRect(self.bounds, cursor: NSCursor.pointingHand)
    }
    
}
