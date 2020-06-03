import Foundation


// MARK: - TagsTextStorage
//
class TagsTextStorage: NSTextStorage {

    private let backingStore = NSMutableAttributedString()

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
        replaceAttachmentCells()

        self.edited(.editedAttributes, range: range, changeInLength: .zero)
        self.endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        self.beginEditing()

        backingStore.setAttributes(attrs, range: range)
        replaceAttachmentCells()

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
        replaceAttachmentCells()

        let change = attrString.length - range.length
        self.edited([.editedCharacters, .editedAttributes], range: range, changeInLength: change)
        self.endEditing()
    }
}


// MARK: - Private API(s)
//
private extension TagsTextStorage {

// TODO: Relocate
    func replaceAttachmentCells() {
        backingStore.enumerateAttachments(of: NSTextAttachment.self) { (attach, range) in
            guard let attachCell = attach.attachmentCell as? NSCell, !(attachCell is TagAttachmentCell) else {
                return
            }

            let tagCell = TagAttachmentCell()
            tagCell.attributedStringValue = attachCell.attributedStringValue
            attach.attachmentCell = tagCell
        }
    }
}
