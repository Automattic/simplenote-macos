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
}
