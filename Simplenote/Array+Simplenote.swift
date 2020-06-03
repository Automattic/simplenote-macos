import Foundation

// MARK: - Simplenote Methods
//
extension Array where Element: Hashable {

    /// Returns a copy of the receiver *containing Unique Elements*.
    ///
    var unique: Array {
        var added = Set<Element>()
        var output = [Element]()

        for element in self where output.contains(element) == false {
            added.insert(element)
            output.append(element)
        }

        return output
    }
}
