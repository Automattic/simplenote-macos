import Foundation
import SimplenoteSearch


// MARK: - TagSuggestionsProcessor
//
class TagSuggestionsProcessor {

    /// Main MOC
    ///
    private let viewContext: NSManagedObjectContext

    /// Storage Lookup
    ///
    private lazy var resultsController = TagSuggestionsResultsController(viewContext: viewContext)

    /// Tag Suggestions Popover
    ///
    private lazy var tagsWindowController: PopoverWindowController = {
        let popoverWindowController = PopoverWindowController()
        popoverWindowController.contentViewController = tagsViewController
        return popoverWindowController
    }()

    /// Tag Suggestions ViewController
    ///
    private lazy var tagsViewController = TagSuggestionsViewController()

    /// Designated Initialier
    ///
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }


    /// This API processes Tag Suggestions for a given Search Query
    ///
    ///     1.  Present (or) refresh Tag Suggestions, whenever the last Item in the Query produces Tag Matches
    ///     2.  Dismiss Tag suggestions if the Query is Empty (or yields no results)
    ///
    func processTagSuggestions(for searchQuery: SearchQuery, in searchField: NSView) {
        guard !searchQuery.isEmpty,
              let tags = resultsController.searchTags(in: searchQuery)
        else {
            dismissTagSuggestions()
            return
        }

        refreshTagSuggestions(tags: tags)
        displayTagSuggestions(around: searchField)
    }

    /// Dismisses the Tags Suggestions UI
    ///
    func dismissTagSuggestions() {
        tagsWindowController.close()
    }
}


// MARK: - Private API(s)
//
private extension TagSuggestionsProcessor {

    func displayTagSuggestions(around searchField: NSView) {
        let parentWindow = searchField.window!

        tagsWindowController.attach(to: parentWindow)
        tagsWindowController.positionWindow(relativeTo: searchField.locationOnScreen)
    }

    func refreshTagSuggestions(tags: [Tag]) {
        tagsViewController.tags = tags
    }

    func setupInterlinkEventListeners() {
        // TODO
    }
}
