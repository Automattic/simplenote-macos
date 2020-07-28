import Foundation


// MARK: - TagTextFormatter
//         Helps us limit the Tag Length in the TagListViewController.
//         We'll always check against the *Simperium Encoded* String
//         (since Tag Names are hashed, and used as Tag.simperiumKey).
//
class TagTextFormatter : Formatter {

    let maximumLength: Int

    init(maximumLength: Int) {
        self.maximumLength = maximumLength
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func string(for obj: Any?) -> String? {
        obj as? String
    }

    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        obj?.pointee = string as AnyObject
        return true
    }

    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        partialString.byEncodingForTagSimperiumKey.count <= maximumLength
    }

    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        nil
    }
}
