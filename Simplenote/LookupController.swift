import Foundation


// MARK: - LookupController
//
class LookupController {

    /// In-Memory Map of Simperium Key > Lookup Note entities. `Superfast search™`
    ///
    private var noteMap = [String: LookupNote]()

    /// Builds the LookupNote Map for a given collection of Notes
    ///
    func preloadLookupTable(for notes: [Note]) {
        for note in notes where note.isDeleted == false {
            guard let title = note.titlePreview, title.isEmpty == false else {
                continue
            }

            noteMap[note.simperiumKey] = LookupNote(simperiumKey: note.simperiumKey, title: title)
        }
    }

    /// Returns all of the LookupNotes whose Title contain the `titleText` search keyword.
    /// - Note: The resulting collection is ordered by Title
    ///
    func search(titleText: String, limit: Int? = nil) -> [LookupNote] {
        let normalizedKeyword = titleText.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil).trimmingCharacters(in: .whitespaces)
        var output = [LookupNote]()

        for note in noteMap.values where note.normalizedTitle.contains(normalizedKeyword) {
            output.append(note)
        }

        let sorted = output.sorted { $0.title < $1.title }
        guard let limit = limit else {
            return sorted
        }

        return Array(sorted.prefix(limit))
    }
}
