import Foundation


// MARK: - Simplenote Extensible Constants
//
extension NSUserInterfaceItemIdentifier {

    /// Identifier: EmptyTrash MenuItem
    ///
    static let emptyTrashMenuItem           = NSUserInterfaceItemIdentifier(rawValue: "emptyTrashMenuItem")

    /// Identifier: Export MenuItem
    ///
    static let exportMenuItem               = NSUserInterfaceItemIdentifier(rawValue: "exportMenuItem")

    /// Identifier: Focus MenuItem
    ///
    static let focusMenuItem                = NSUserInterfaceItemIdentifier(rawValue: "focusMenuItem")

    /// Identifier: Tags Sort MenuItem
    ///
    static let tagSortMenuItem              = NSUserInterfaceItemIdentifier(rawValue: "tagSortMenuItem")

    /// Identifiers: System Menu
    ///
    static let systemNewNoteMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "systemNewNoteMenuItem")
    static let systemTrashMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "systemTrashMenuItem")
    static let systemPrintMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "systemPrintMenuItem")

    /// Identifiers: Notes List Menu
    ///
    static let noteDisplayComfyMenuItem     = NSUserInterfaceItemIdentifier(rawValue: "noteDisplayComfyMenuItem")
    static let noteDisplayCondensedMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteDisplayCondensedMenuItem")
    static let noteSortAlphaMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "noteSortAlphaMenuItem")
    static let noteSortUpdatedMenuItem      = NSUserInterfaceItemIdentifier(rawValue: "noteSortUpdatedMenuItem")

    /// Identifiers: Editor
    ///
    static let editorPinMenuItem            = NSUserInterfaceItemIdentifier(rawValue: "editorPinMenuItem")
    static let editorMarkdownMenuItem       = NSUserInterfaceItemIdentifier(rawValue: "editorMarkdownMenuItem")
    static let editorShareMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "editorShareMenuItem")
    static let editorHistoryMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "editorHistoryMenuItem")
    static let editorTrashMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "editorTrashMenuItem")
    static let editorPublishMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "editorPublishMenuItem")
    static let editorCollaborateMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "editorCollaborateMenuItem")

    /// Identifiers: Line Settings
    ///
    static let lineNarrowMenuItem           = NSUserInterfaceItemIdentifier(rawValue: "lineNarrowMenuItem")
    static let lineFullMenuItem             = NSUserInterfaceItemIdentifier(rawValue: "lineFullMenuItem")

    /// Identifiers: Theme Menu
    ///
    static let themeDarkMenuItem            = NSUserInterfaceItemIdentifier(rawValue: "themeDarkMenuItem")
    static let themeLightMenuItem           = NSUserInterfaceItemIdentifier(rawValue: "themeLightMenuItem")
    static let themeSystemMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "themeSystemMenuItem")
}
