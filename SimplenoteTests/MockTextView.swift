import Foundation

// MARK: - MockupTextView: Useful for Unit Testing purposes.
//         NSTextView(s) not properly attached to a window lack UndoManager
//
class MockTextView: NSTextView {

    let internalUndoManager = UndoManager()

    override var undoManager: UndoManager? {
        return internalUndoManager
    }
}

// MARK: - MockupTextViewDelegate: Useful for Unit Testing Purposes
//
class MockupTextViewDelegate: NSObject, NSTextViewDelegate {

    var receivedTextDidChangeNotifications = [Notification]()

    func reset() {
        receivedTextDidChangeNotifications.removeAll()
    }

    func textDidChange(_ notification: Notification) {
        receivedTextDidChangeNotifications.append(notification)
    }
}
