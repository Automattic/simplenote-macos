import Foundation

extension NSAlert {
    convenience init(messageText: String, informativeText: String) {
        self.init()
        self.messageText = messageText
        self.informativeText = informativeText
    }

    static func presentAlert(withMessageText messageText: String,
                             informativeText: String,
                             for window: Window,
                             onCompletion: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert = NSAlert(messageText: messageText, informativeText: informativeText)
        alert.beginSheetModal(for: window, completionHandler: onCompletion)
    }
}
