import Foundation

// MARK: - Note + Interlink
//
extension Note {

    /// Returns the receiver's Markdown Internal Reference, when possible
    ///
    var plainInterlink: String? {
        guard let key = simperiumKey else {
            return nil
        }

        return SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/" + key
    }

    /// Returns the receiver's Markdown Internal Reference, when possible
    ///
    var markdownInterlink: String? {
        guard let title = titlePreview, let interlink = plainInterlink else {
            return nil
        }

        let shortened = title.truncateWords(upTo: SimplenoteConstants.simplenoteInterlinkMaxTitleLength)
        return "[" + shortened + "](" + interlink + ")"
    }
}
