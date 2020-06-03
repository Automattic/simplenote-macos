import Foundation


// MARK: - Helpers
//
extension Note {

    /// Given a collection of Tag Names, this API will return the subset that's not already associated with the receiver.
    ///
    func filterUnassociatedTagNames(from names: [String]) -> [String] {
        return names.filter { name in
            self.hasTag(name) == false
        }
    }
}
