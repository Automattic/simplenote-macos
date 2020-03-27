import Foundation


// MARK: - NSRegularExpression Simplenote Methods
//
extension NSRegularExpression {

    /// Matches Leading Whitespaces
    ///
    @objc
    static let regexForLeadingSpaces: NSRegularExpression = {
        try! NSRegularExpression(pattern: "^\\s+", options: [])
    }()

    /// Matches Checklists at the beginning of each line
    ///
    @objc
    static let regexForChecklists: NSRegularExpression = {
        try! NSRegularExpression(pattern: "^\\s*(-[ \t]+\\[[xX\\s]?\\])", options: .anchorsMatchLines)
    }()

    /// Both our Checklist regexes look like this: `"^\\s*(EXPRESSION)"`
    /// This will produce two resulting NSRange(s): a top level one, including the full match, and a "capture group"
    /// By requesting the Range for `EXPRESSION` we'd be able to track **exactly** the location of our list marker `- [ ]` (disregarding, thus, the leading space).
    ///
    @objc
    static let regexForChecklistsExpectedNumberOfRanges = 2

    /// Checklist's Match Marker Range
    ///
    @objc
    static let regexForChecklistsMarkerRangeIndex = 1

}
