import Foundation


// MARK: - NoteListPrefixFormatter
//
struct NoteListPrefixFormatter {

    /// Let's... reuse the formatter?
    ///
    static let shared = NoteListPrefixFormatter()


    /// Returns a Prefix for the specified Note, matching a given SortMode
    ///
    func prefix(from note: Note, for sortMode: SortMode) -> String? {
        guard let date = date(from: note, for: sortMode) else {
            return nil
        }

        return DateFormatter.notesFormatter.string(from: date)
    }

    /// Returns the relevant Note Date field for the specified Sort Mode
    ///
    private func date(from note: Note, for sortMode: SortMode) -> Date? {
        switch sortMode {
        case .alphabeticallyAscending, .alphabeticallyDescending:
            return nil

        case .createdNewest, .createdOldest:
            return note.creationDate

        case .modifiedNewest, .modifiedOldest:
            return note.modificationDate
        }
    }
}
