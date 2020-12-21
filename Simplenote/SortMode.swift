import Foundation


// MARK: - Sort Modes
//
enum SortMode: Int, CaseIterable {

    /// Alphabetically: A-Z / Z-A
    ///
    case alphabeticallyAscending
    case alphabeticallyDescending

    /// Created: Newest / Oldest Top
    ///
    case createdNewest
    case createdOldest

    /// Modified: Newest / Oldest on Top
    ///
    case modifiedNewest
    case modifiedOldest
}


// MARK: - Public Methods
//
extension SortMode {

    var description: String {
        switch self {
        case .alphabeticallyAscending:
            return NSLocalizedString("Alphabetically: A-Z", comment: "Sort Mode: Alphabetically, ascending")
        case .alphabeticallyDescending:
            return NSLocalizedString("Alphabetically: Z-A", comment: "Sort Mode: Alphabetically, descending")
        case .createdNewest:
            return NSLocalizedString("Created: Newest", comment: "Sort Mode: Creation Date, descending")
        case .createdOldest:
            return NSLocalizedString("Created: Oldest", comment: "Sort Mode: Creation Date, ascending")
        case .modifiedNewest:
            return NSLocalizedString("Modified: Newest", comment: "Sort Mode: Modified Date, descending")
        case .modifiedOldest:
            return NSLocalizedString("Modified: Oldest", comment: "Sort Mode: Modified Date, ascending")
        }
    }
}


// MARK: - Notes List SortMode <> Interface Identifier
//
extension SortMode {

    /// Initializes a new Sort Mode given a **Note List** Interface Identifier: NSMenuItem Reference
    ///
    init?(noteListInterfaceID: NSUserInterfaceItemIdentifier) {
        switch noteListInterfaceID {
        case .noteSortAlphaAscMenuItem:
            self = .alphabeticallyAscending
        case .noteSortAlphaDescMenuItem:
            self = .alphabeticallyDescending
        case .noteSortCreateNewestMenuItem:
            self = .createdNewest
        case .noteSortCreateOldestMenuItem:
            self = .createdOldest
        case .noteSortModifyNewestMenuItem:
            self = .modifiedNewest
        case .noteSortModifyOldestMenuItem:
            self = .modifiedOldest
        default:
            return nil
        }
    }

    /// Returns the Notes List matching Interface Identifier
    ///
    var noteListInterfaceID: NSUserInterfaceItemIdentifier {
        switch self {
        case .alphabeticallyAscending:
            return .noteSortAlphaAscMenuItem
        case .alphabeticallyDescending:
            return .noteSortAlphaDescMenuItem
        case .createdNewest:
            return .noteSortCreateNewestMenuItem
        case .createdOldest:
            return .noteSortCreateOldestMenuItem
        case .modifiedNewest:
            return .noteSortModifyNewestMenuItem
        case .modifiedOldest:
            return .noteSortModifyOldestMenuItem
        }
    }
}
