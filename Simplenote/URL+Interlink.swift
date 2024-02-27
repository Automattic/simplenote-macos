import Foundation

// MARK: - URL + Interlink
//
extension URL {

    /// Indicates if the receiver' has the Simplenote Scheme
    ///
    var isSimplenoteURL: Bool {
        scheme?.lowercased() == SimplenoteConstants.simplenoteScheme
    }

    /// Indicates if the receiver is a reference to a Note
    ///
    var isInterlinkURL: Bool {
        isSimplenoteURL && host?.lowercased() == SimplenoteConstants.simplenoteInterlinkHost
    }

    /// Extracts the Internal Note's SimperiumKey, whenever the receiver is an Interlink URL
    ///
    var interlinkSimperiumKey: String? {
        guard isInterlinkURL else {
            return nil
        }

        return path.replacingOccurrences(of: "/", with: "")
    }
}
