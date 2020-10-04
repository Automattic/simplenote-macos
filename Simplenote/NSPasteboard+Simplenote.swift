import Foundation


// MARK: - NSPasteboard + Interlink
//
extension NSPasteboard {

    /// Copies the Internal Link (Markdown Reference) into the OS Pasteboard
    ///
    func copyInterlink(to note: Note) {
        guard let link = note.markdownInternalLink else {
            return
        }

        declareTypes([.string], owner: nil)
        setString(link, forType: .string)
    }
}
