import Cocoa


@objc(SPApplication)
final class SPApplication: NSApplication {
    override func sendEvent(_ event: NSEvent) {
        guard event.type == .keyDown else {
            super.sendEvent(event)
            return
        }

        let appDelegate = SimplenoteAppDelegate.shared()
        let modifierFlags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if  modifierFlags == .command &&
            event.charactersIgnoringModifiers == "l" {

            appDelegate.searchWasPressed(self)
            return
        }

        if modifierFlags == .command &&
            event.simplenoteSpecialKey == .some(.carriageReturn) &&
            appDelegate.window.firstResponder is SPTextView {

            appDelegate.focusOnTheNoteList()
            return
        }

        // We're using `sendAction` in the following methods to make sure the action is delivered through the current responder chain
        if modifierFlags == [.command, .shift] &&
            event.charactersIgnoringModifiers == "Y" {

            if sendAction(#selector(NoteEditorViewController.toggleTagsAndEditor), to: nil, from: self) {
                return
            }
        }

        if modifierFlags.intersection([.shift, .command, .control, .option]).isEmpty {
            if event.simplenoteSpecialKey == .some(.trailingArrow) {
                if sendAction(#selector(NoteListViewController.switchToTrailingPanel), to: nil, from: self) {
                    return
                }
            }

            if event.simplenoteSpecialKey == .some(.leadingArrow) {
                if sendAction(#selector(NoteListViewController.switchToLeadingPanel), to: nil, from: self) {
                    return
                }
            }
        }

        super.sendEvent(event)
    }
}
