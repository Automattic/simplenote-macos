import Foundation

// MARK: - Simplenote Methods
//
extension Array where Element == String {

    /// Returns a copy of the receiver containing Unique Strings (case insensitive comparison!)
    ///
    var caseInsensitiveUnique: [String] {
        var seen = Set<String>()
        var output = [String]()

        for string in self {
            let lowercased = string.lowercased()
            if seen.contains(lowercased) {
                continue
            }

            output.append(string)
            seen.insert(lowercased)
        }

        return output
    }
}

// MARK: - Array + NSView Convenience API
//
extension Array where Element == NSView {

    func updateAlphaValue(_ newAlpha: CGFloat) {
        forEach { view in
            view.alphaValue = newAlpha
        }
    }
}
