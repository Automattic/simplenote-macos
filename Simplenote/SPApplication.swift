import Cocoa

@objc(SPApplication)
final class SPApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown else {
            super.sendEvent(event)
            return
        }

        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command &&
            event.charactersIgnoringModifiers == "l" {
            SimplenoteAppDelegate.shared().searchWasPressed(self)
            return
        }

        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command &&
            event.simplenoteSpecialKey == .some(.carriageReturn) &&
            SimplenoteAppDelegate.shared().window.firstResponder is SPTextView {

            SimplenoteAppDelegate.shared().noteListViewController.focusOnTheList()
            return
        }

        super.sendEvent(event)
    }
}
