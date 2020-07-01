import Foundation


// MARK: - NoteVersion
//
class NoteVersion: NSObject {

    /// Note's Payload
    ///
    let content: String

    /// Latest modification date
    ///
    let modificationDate: Date


    /// Designed Initializer
    ///
    init?(payload: NSDictionary) {
        guard let modification = payload[Keys.modificationDate.rawValue] as? Double,
            let content = payload[Keys.content.rawValue] as? String
            else {
                return nil
        }

        self.modificationDate = Date(timeIntervalSince1970: TimeInterval(modification))
        self.content = content
    }
}


// MARK: - Parsing Keys
//
extension NoteVersion {

    private enum Keys: String {
        case modificationDate
        case content
    }
}
