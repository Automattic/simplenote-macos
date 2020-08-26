import Foundation
import AppKit


// MARK: - NSNotification Simplenote Methods
//
extension NSNotification {

    /// Returns the associated FieldEditor (if any)
    ///
    @objc
    var fieldEditor: NSTextView? {
        userInfo?["NSFieldEditor"] as? NSTextView
    }
}
