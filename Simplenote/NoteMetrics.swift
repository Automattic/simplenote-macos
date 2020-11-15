import Foundation


// MARK: - NoteMetrics
//
struct NoteMetrics {

    /// Returns the total number of characters
    ///
    let numberOfChars: String

    /// Returns the total number of words
    ///
    let numberOfWords: String

    /// Creation Date (whenever we're in single selection mode)
    ///
    let creationDate: String?

    /// Modification Date (whenever we're in single selection mode)
    ///
    let modifiedDate: String?


    /// Designed Initializer
    /// - Parameter notes: Notes from which we should extract metrics
    ///
    init(notes: [Note]) {
        let contents = notes.compactMap({ $0.content }).reduce("", +)
        let dateProviderNote = notes.count == 1 ? notes.first : nil
        let wordCount = NSSpellChecker.shared.countWords(in: contents, language: nil)
        let safeWordCount = wordCount != -1 ? wordCount : .zero

        numberOfChars = NumberFormatter.localizedString(from: contents.count, style: .decimal)

        numberOfWords = NumberFormatter.localizedString(from: safeWordCount, style: .decimal)

        creationDate = dateProviderNote?.creationDate.map {
            DateFormatter.metricsFormatter.string(from: $0)
        }

        modifiedDate = dateProviderNote?.modificationDate.map {
            DateFormatter.metricsFormatter.string(from: $0)
        }
    }
}
