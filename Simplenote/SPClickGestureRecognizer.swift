//
//  SPClickGestureRecognizer.swift
//  Simplenote
//

import Cocoa

@objc class SPClickGestureRecognizer: NSClickGestureRecognizer {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPrevent(_ preventedGestureRecognizer: NSGestureRecognizer) -> Bool {
        return false
    }
    
    override func canBePrevented(by preventingGestureRecognizer: NSGestureRecognizer) -> Bool {
        return false
    }
}
