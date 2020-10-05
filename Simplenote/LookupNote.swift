import Foundation


// MARK: - Lookup Note
//
struct LookupNote {

    ///
    ///
    let simperiumKey: String

    ///
    ///
    let title: String

    ///
    ///
    var normalizedTitle: String {
        title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
    }
}
