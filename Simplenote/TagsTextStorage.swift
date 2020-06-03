import Foundation


// MARK: - TagsTextStorage
//
class TagsTextStorage: NSTextStorage {

    /// Internal Storage
    ///
    private let backingStore = NSMutableAttributedString()

    /// Callback executed whenever a NSTextAttachment is Upsert
    ///
    var onAttachmentUpsert: ((NSAttributedString) -> Void)?


    override var string: String {
        backingStore.string
    }

    override init(attributedString attrStr: NSAttributedString) {
        super.init()
        backingStore.setAttributedString(attrStr)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        super.init(pasteboardPropertyList: propertyList, ofType: type)
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return backingStore.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        self.beginEditing()

        backingStore.replaceCharacters(in: range, with: str)
        let change = str.utf16.count - range.length

        self.edited(.editedCharacters, range: range, changeInLength: change)
        self.endEditing()
    }

    override func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange) {
        self.beginEditing()

        backingStore.addAttribute(name, value: value, range: range)

        if name == .attachment {
            onAttachmentUpsert?(backingStore)
        }

        self.edited(.editedAttributes, range: range, changeInLength: .zero)
        self.endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        self.beginEditing()

        backingStore.setAttributes(attrs, range: range)

        if let _ = attrs?[.attachment]  {
            onAttachmentUpsert?(backingStore)
        }

        self.edited(.editedAttributes, range: range, changeInLength: .zero)
        self.endEditing()
    }

    override func removeAttribute(_ name: NSAttributedString.Key, range: NSRange) {
        self.beginEditing()

        backingStore.removeAttribute(name, range: range)

        self.edited(.editedAttributes, range: range, changeInLength: .zero)
        self.endEditing()
    }

    override func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) {
        self.beginEditing()

        backingStore.replaceCharacters(in: range, with: attrString)

        if attrString.numberOfAttachments > .zero {
            onAttachmentUpsert?(backingStore)
        }

        let change = attrString.length - range.length
        self.edited([.editedCharacters, .editedAttributes], range: range, changeInLength: change)
        self.endEditing()
    }
}
