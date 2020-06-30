import Foundation
import AppKit


/// NSTableCellView Helpers
///
extension NSTableCellView {

    /// Returns a reuseIdentifier that matches the receiver's classname (non namespaced).
    ///
    class var reuseIdentifier: NSUserInterfaceItemIdentifier {
        NSUserInterfaceItemIdentifier(classNameWithoutNamespaces)
    }
}
