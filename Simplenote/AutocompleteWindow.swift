import Foundation
import AppKit


// MARK: - AutocompleteWindow
//
// This class renders an Autocomplete Window: the Parent Window is expected to rely events via the `ParentWindowDelegate` protocol.
//
//  - Will get dismissed whenever any Mouse Event happens in the Parent
//  - Captures Arrow Up / Down / Return / Esc key events happening in the parent
//
class AutocompleteWindow: Window {

}


// MARK: - ParentWindowDelegate
//
extension AutocompleteWindow: ParentWindowDelegate {

    /// Handles Events happening in the Parent Window.
    /// - Note: Returning `true` will cause the parent not to forward the Event.
    ///
    func processParentWindowEvent(_ event: NSEvent) -> Bool {
        guard isVisible else {
            return false
        }

        switch event.type {
        case .keyDown:
            return processKeyDownInParent(event)

        case .leftMouseDown, .rightMouseDown, .otherMouseDown, .scrollWheel:
            return processMouseEventInParent(event)

        default:
            return false
        }
    }
}


// MARK: - Private API(s)
//
private extension AutocompleteWindow {

    /// Capture Up / Down / Return / Escape!!
    ///
    func processKeyDownInParent(_ event: NSEvent) -> Bool {
        guard let key = event.simplenoteSpecialKey else {
            return false
        }

        switch key {
        case .upArrow, .downArrow, .carriageReturn:
            sendEvent(event)
            return true

        case .esc:
            close()
            return true

        default:
            return false
        }
    }

    /// Dismiss the receiver whenever there's a mouse event happening in the Parent
    ///
    func processMouseEventInParent(_ event: NSEvent) -> Bool {
        close()
        return false
    }
}
