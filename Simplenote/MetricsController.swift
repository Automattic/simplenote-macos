import Foundation


// MARK: - MetricsController
//
class MetricsController {

    /// Collection of Notes being observed
    ///
    private(set) var notes: [Note] = []

    /// Returns the result of combining all of the observed note's contents
    ///
    private var contents: String {
        notes.compactMap({ $0.content }).reduce("", +)
    }

    /// Closure to be invoked whenever the observed objects are updated
    ///
    var onChange: (() -> Void)?


    /// Starts observing changes over a given collection of Notes, and invokes `onChange` when any of such entities is updated.
    /// - Note: The very first time this API is invoked, it'll call `onChange` back
    ///
    func startReportingMetrics(for notes: [Note]) {
// TODO: Start listening for changes
        self.notes = notes
        onChange?()
    }
}


// MARK: - Public Properties
//
extension MetricsController {

    /// Indicates if Date Fields must be rendered: Skip them when there are multiple notes selected
    ///
    private var displayDateFields: Bool {
        notes.count == 1
    }

    /// Returns the Note's Creation Date (whenever we're in single selection mode)
    ///
    var creationDate: Date? {
        displayDateFields ? notes.first?.creationDate : nil
    }

    /// Returns the Note's Modification Date (whenever we're in single selection mode)
    ///
    var modifiedDate: Date? {
        displayDateFields ? notes.first?.modificationDate : nil
    }

    /// Returns the total number of characters
    ///
    var numberOfChars: Int {
        contents.count
    }

    /// Returns the total number of words
    ///
    var numberOfWords: Int {
        notes.isEmpty ? .zero : NSSpellChecker.shared.countWords(in: contents, language: nil)
    }
}
