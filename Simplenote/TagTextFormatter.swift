import Foundation


// MARK: - TagTextFormatter: Helps us limit the Tag Length in the TagListViewController.
//
class TagTextFormatter : Formatter {

    /// Maximum Allowed Tag Length
    ///
    let maximumLength: Int

    /// Indicates if spaces are entirely disallowed
    ///
    let disallowSpaces: Bool

    /// Designated Initializer
    /// - Parameters:
    ///     - maximumLength: Maximum allowed (encoded) Tag Length
    ///     - disallowSpaces: Indicates if the formatter should deny any kind of input that contains spaces
    ///
    init(maximumLength: Int, disallowSpaces: Bool = false) {
        self.maximumLength = maximumLength
        self.disallowSpaces = disallowSpaces
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

    /// Indicates if a Partial Edition is valid:
    /// - Note: We'll remove Attachment Markers from the input. Useful for NSTokenField usage
    /// - Important: Maximum Tag Length is enforced against the `byEncodingAsTagHash` output string length, because
    ///              `Tag.simperiumKey` fields are actually derived from the Tag Name.
    ///
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if disallowSpaces, partialString.contains(String.space) {
            return false
        }

        let encodedString = partialString
                                .replacingOccurrences(of: String.attachmentString, with: "")
                                .trimmingCharacters(in: .whitespaces)
                                .byEncodingAsTagHash

        return encodedString.count <= maximumLength
    }

    override func attributedString(for obj: Any, withDefaultAttributes attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString? {
        nil
    }
}
