import Foundation


// MARK: - Helpers
//
extension Note {

    /// Given a collection of tags, this API will return the subset that's not already included by the receiver
    ///
    func filterMissingTokens(_ tokens: [String]) -> [String] {
        return tokens.filter { tag in
            self.hasTag(tag) == false
        }
    }
}
