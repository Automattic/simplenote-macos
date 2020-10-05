import Foundation


// MARK: - Note + Interlink
//
extension Note {

    /// Returns the receiver's Markdown Internal Reference, when possible
    ///
    var markdownInternalLink: String? {
        guard let title = titlePreview, let simperiumKey = simperiumKey else {
            return nil
        }

        return String.buildInterlink(title: title, simperiumKey: simperiumKey)
    }
}


// MARK: - String + Interlink
//
extension String {

    /// Returns an Interlink for a Note with the specified Title / Key
    ///
    static func buildInterlink(title: String, simperiumKey: String) -> String {
        let shortened = title.truncateWords(upTo: SimplenoteConstants.simplenoteInterlinkMaxTitleLength)
        let url = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/" + simperiumKey

        return "[" + shortened + "](" + url + ")"
    }
}
