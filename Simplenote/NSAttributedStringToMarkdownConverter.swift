import Cocoa


// MARK: - NSAttributedString to Markdown Converter
//
class NSAttributedStringToMarkdownConverter: NSObject {

    /// Markdown replacement for "Unchecked Checklist"
    ///
    private let unchecked = "- [ ]"

    /// Markdown replacement for "Checked Checklist"
    ///
    private let checked = "- [x]"


    /// Returns the NSString representation of a given NSAttributedString.
    ///
    @objc
    func convert(string: NSAttributedString) -> NSString {
        let adjusted = NSMutableAttributedString(attributedString: string)
        adjusted.enumerateAttribute(.attachment, in: adjusted.rangeOfEntireString, options: .reverse) { (value, range, _) in
            guard let attachment = value as? SPTextAttachment else {
                return
            }

            let markdown = attachment.isChecked ? checked : unchecked
            adjusted.replaceCharacters(in: range, with: markdown)
        }

        return adjusted.string as NSString
    }
}
