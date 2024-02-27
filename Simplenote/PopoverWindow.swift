import Foundation
import AppKit

// MARK: - AutocompleteWindow
//
// This class renders a PopoverWindow: the Parent Window is expected to rely events via the `ParentWindowDelegate` protocol.
//
//  - Will get dismissed whenever any Mouse Event happens in the Parent
//  - Captures Arrow Up / Down / Return / Esc key events happening in the parent
//
class PopoverWindow: Window {

}

// MARK: - ParentWindowDelegate
//
extension PopoverWindow: ParentWindowDelegate {

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
private extension PopoverWindow {

    /// Capture Up / Down / Return / Escape!!
    ///
    func processKeyDownInParent(_ event: NSEvent) -> Bool {
        let excludedFlags: NSEvent.ModifierFlags = [.shift, .command, .control]
        guard event.modifierFlags.intersection(excludedFlags).isEmpty else {
            return false
        }

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
