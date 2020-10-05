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
    let normalizedTitle: String


    /// Designated Initializer
    ///
    init(simperiumKey: String, title: String) {
        self.simperiumKey = simperiumKey
        self.title = title
        self.normalizedTitle = title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
    }
}
