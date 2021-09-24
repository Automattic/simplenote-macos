import Foundation

extension NSButton {
    func setTitleColor(_ color: NSColor) {
        let currentTitle = NSMutableAttributedString(string: title)
        currentTitle.addAttribute(.foregroundColor, value: color, range: currentTitle.fullRange)
        attributedTitle = currentTitle
    }
}
