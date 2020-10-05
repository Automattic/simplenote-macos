import Foundation


// MARK: - LookupController
//
class LookupController {

    private var noteMap = [String: LookupNote]()

    func preloadLookupTable(for notes: [Note]) {
        for note in notes where note.isDeleted == false {
            guard let title = note.titlePreview, title.isEmpty == false else {
                continue
            }

            noteMap[note.simperiumKey] = LookupNote(simperiumKey: note.simperiumKey, title: title)
        }
    }

    func search(titleText: String, limit: Int? = nil) -> [LookupNote] {
        let normalizedKeyword = titleText.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)

        var output = [LookupNote]()
        for note in noteMap.values where note.normalizedTitle.contains(normalizedKeyword) {
            output.append(note)
        }

        let sorted = output.sorted { $0.normalizedTitle < $1.normalizedTitle }
        guard let limit = limit else {
            return sorted
        }

        return Array(sorted.prefix(limit))
    }
}
