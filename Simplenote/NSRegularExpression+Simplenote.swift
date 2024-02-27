import Foundation

// MARK: - NSRegularExpression Simplenote Methods
//
extension NSRegularExpression {

    /// Matches Leading Whitespaces
    ///
    static let regexForLeadingSpaces: NSRegularExpression = {
        try! NSRegularExpression(pattern: "^\\s+", options: [])
    }()

    /// Matches Checklists at the beginning of each line
    ///
    @objc
    static let regexForListMarkers: NSRegularExpression = {
        try! NSRegularExpression(pattern: "^\\s*(-[ \t]+\\[[xX\\s]?\\])", options: .anchorsMatchLines)
    }()

    /// Matches Checklists patterns that can be ANYWHERE in the string, not necessarily at the beginning of the string.
    ///
    @objc
    static let regexForListMarkersEmbeddedAnywhere: NSRegularExpression = {
        try! NSRegularExpression(pattern: "\\s*(-[ \t]+\\[[xX\\s]?\\])", options: .anchorsMatchLines)
    }()

    /// `regexForListMarkers` looks like this: `"^\\s*(EXPRESSION)"`
    /// This produces two resulting NSRange(s): a top level one, including the full match, and a "capture group".
    /// By requesting the Range for `EXPRESSION` we'd be able to track **exactly** the location of our list marker `- [ ]`
    /// (disregarding, thus, the leading space).
    ///
    @objc
    static let regexForListMarkersExpectedNumberOfRanges = 2

    /// ListMarker RegEx Replacement Range
    ///
    @objc
    static let regexForListMarkersReplacementRangeIndex = 1

}
