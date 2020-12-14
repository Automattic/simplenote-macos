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

    var inverse: SortMode {
        switch self {
        case .alphabeticallyAscending:
            return .alphabeticallyDescending
        case .alphabeticallyDescending:
            return .alphabeticallyAscending
        case .createdNewest:
            return .createdOldest
        case .createdOldest:
            return .createdNewest
        case .modifiedNewest:
            return .modifiedOldest
        case .modifiedOldest:
            return .modifiedNewest
        }
    }

    var isAlphabetical: Bool {
        self == .alphabeticallyAscending || self == .alphabeticallyDescending
    }

    var isCreated: Bool {
        self == .createdNewest || self == .createdOldest
    }

    var isUpdated: Bool {
        self == .modifiedNewest || self == .modifiedOldest
    }

    var isReversed: Bool {
        self == .alphabeticallyDescending || self == .modifiedOldest || self == .createdOldest
    }
}
