import AppKit

// MARK: - SPTextView
//
extension SPTextView {
    open override func copy(_ sender: Any?) {
        guard selectedRange().location != NSNotFound else {
            return
        }

        let selectedAttributedString = attributedString().attributedSubstring(from: selectedRange())
        let markdownString = NSAttributedStringToMarkdownConverter.convert(string: selectedAttributedString)

        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(markdownString, forType: .string)
    }
}
