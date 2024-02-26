import Foundation

// MARK: - Version
//
struct Version {

    /// Version
    ///
    let version: String

    /// Note's Payload
    ///
    let content: String

    /// Latest modification date
    ///
    let modificationDate: Date

    /// Designed Initializer
    ///
    init?(version: String, payload: [AnyHashable: Any]) {
        guard let modification = payload[Keys.modificationDate.rawValue] as? Double,
            let content = payload[Keys.content.rawValue] as? String
            else {
                return nil
        }

        self.version = version
        self.modificationDate = Date(timeIntervalSince1970: TimeInterval(modification))
        self.content = content
    }
}

// MARK: - Parsing Keys
//
extension Version {

    private enum Keys: String {
        case modificationDate
        case content
    }
}
