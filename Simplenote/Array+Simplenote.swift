import Foundation

// MARK: - Simplenote Methods
//
extension Array where Element: Hashable {

    /// Returns a copy of the receiver *containing Unique Elements*.
    ///
    var unique: Array {
        guard let output = NSOrderedSet(array: self).array as? [Element] else {
            return self
        }

        return output
    }
}
