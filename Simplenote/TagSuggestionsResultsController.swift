import Foundation
import SimplenoteFoundation
import SimplenoteSearch


// MARK: - TagSuggestionsResultsController
//
class TagSuggestionsResultsController {

    /// ResultsController: In charge of CoreData Queries!
    ///
    private let resultsController: ResultsController<Tag>

    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext, maximumNumberOfResults: Int = Settings.maximumNumberOfResults) {
        let sortDescriptors = [ NSSortDescriptor.descriptorForTags() ]
        resultsController = ResultsController<Tag>(viewContext: viewContext,
                                                   sortedBy: sortDescriptors,
                                                   limit: maximumNumberOfResults)
    }


    /// Returns the collection of Tags matching the last entry in a givne SearchQuery (excluding exact matches!)
    /// - Important: Returns `nil` when there are no results!
    ///
    func searchTags(in searchQuery: SearchQuery) -> [Tag]? {
        resultsController.predicate = NSPredicate.predicateForTags(in: searchQuery)
        try? resultsController.performFetch()

        let result = resultsController.fetchedObjects
        return result.isEmpty ? nil : result
    }
}


// MARK: - Settings!
//
private enum Settings {
    static let maximumNumberOfResults = 5
}
