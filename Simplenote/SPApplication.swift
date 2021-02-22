import Cocoa


@objc(SPApplication)
final class SPApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown else {
            super.sendEvent(event)
            return
        }

        let excludedFlags: NSEvent.ModifierFlags = [.shift, .command, .control, .option]

        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if  modifierFlags == .command &&
            event.charactersIgnoringModifiers == "l" {

            if sendAction(Selector(("searchWasPressed:")), to: nil, from: self) {
                return
            }
        }

        if modifierFlags == .command &&
            event.simplenoteSpecialKey == .some(.carriageReturn) &&
            SimplenoteAppDelegate.shared().window.firstResponder is SPTextView {

            if sendAction(Selector(("focusOnTheNoteList")), to: nil, from: self) {
                return
            }
        }

        if modifierFlags == [.command, .shift] &&
            event.charactersIgnoringModifiers == "Y" {

            if sendAction(Selector(("toggleTagsAndEditor")), to: nil, from: self) {
                return
            }
        }

        if modifierFlags.intersection(excludedFlags).isEmpty {
            if event.simplenoteSpecialKey == .some(.rightArrow) {
                if sendAction(Selector(("switchToRightPanel")), to: nil, from: self) {
                    return
                }
            }

            if event.simplenoteSpecialKey == .some(.leftArrow) {
                if sendAction(Selector(("switchToLeftPanel")), to: nil, from: self) {
                    return
                }
            }
        }

        super.sendEvent(event)
    }
}
