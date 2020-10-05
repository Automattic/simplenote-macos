import Foundation


// MARK: - Lookup Note
//
struct LookupNote {

    /// Associated Note's Simperium Key
    ///
    let simperiumKey: String

    /// Associated Note's Title
    ///
    let title: String

    /// Returns the receiver's Markdown Internal Reference
    ///
    var markdownInternalLink: String {
        String.buildInterlink(title: title, simperiumKey: simperiumKey)
    }

    /// Diacritic and Case Insensitive Title, for matching purposes
    ///
    var normalizedTitle: String {
        title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
    }
}
