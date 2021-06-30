import Foundation


// MARK: - Simplenote Extensible Constants
//
extension NSUserInterfaceItemIdentifier {

    /// Identifier: Simplenote Menu
    ///
    static let emptyTrashMenuItem           = NSUserInterfaceItemIdentifier(rawValue: "emptyTrashMenuItem")
    static let exportMenuItem               = NSUserInterfaceItemIdentifier(rawValue: "exportMenuItem")

    /// Identifiers: System Menu
    ///
    static let systemNewNoteMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "systemNewNoteMenuItem")
    static let systemTrashMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "systemTrashMenuItem")
    static let systemPrintMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "systemPrintMenuItem")

    /// Identifiers: View Menu
    ///
    static let lineNarrowMenuItem           = NSUserInterfaceItemIdentifier(rawValue: "lineNarrowMenuItem")
    static let lineFullMenuItem             = NSUserInterfaceItemIdentifier(rawValue: "lineFullMenuItem")
    static let noteDisplayComfyMenuItem     = NSUserInterfaceItemIdentifier(rawValue: "noteDisplayComfyMenuItem")
    static let noteDisplayCondensedMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteDisplayCondensedMenuItem")
    static let noteSortAlphaAscMenuItem     = NSUserInterfaceItemIdentifier(rawValue: "noteSortAlphaAscMenuItem")
    static let noteSortAlphaDescMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "noteSortAlphaDescMenuItem")
    static let noteSortCreateNewestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortCreateNewestMenuItem")
    static let noteSortCreateOldestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortCreateOldestMenuItem")
    static let noteSortModifyNewestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortModifyNewestMenuItem")
    static let noteSortModifyOldestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortModifyOldestMenuItem")
    static let tagSortMenuItem              = NSUserInterfaceItemIdentifier(rawValue: "tagSortMenuItem")
    static let themeDarkMenuItem            = NSUserInterfaceItemIdentifier(rawValue: "themeDarkMenuItem")
    static let themeLightMenuItem           = NSUserInterfaceItemIdentifier(rawValue: "themeLightMenuItem")
    static let themeSystemMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "themeSystemMenuItem")
    static let focusMenuItem                = NSUserInterfaceItemIdentifier(rawValue: "focusMenuItem")
    static let sidebarMenuItem              = NSUserInterfaceItemIdentifier(rawValue: "sidebarMenuItem")
    static let toggleMarkdownPreview        = NSUserInterfaceItemIdentifier(rawValue: "toggleMarkdownPreview")

    /// Identifiers: Notes List
    ///
    static let listCopyInterlinkMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "listCopyInterlinkMenuItem")
    static let listDeleteForeverMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "listDeleteForeverMenuItem")
    static let listPinMenuItem              = NSUserInterfaceItemIdentifier(rawValue: "listPinMenuItem")
    static let listRestoreNoteMenuItem      = NSUserInterfaceItemIdentifier(rawValue: "listRestoreNoteMenuItem")
    static let listTrashNoteMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "listTrashNoteMenuItem")

    /// Identifiers: Editor
    ///
    static let editorPinMenuItem            = NSUserInterfaceItemIdentifier(rawValue: "editorPinMenuItem")
    static let editorMarkdownMenuItem       = NSUserInterfaceItemIdentifier(rawValue: "editorMarkdownMenuItem")
    static let editorCopyInterlinkMenuItem  = NSUserInterfaceItemIdentifier(rawValue: "editorCopyInterlinkMenuItem")
    static let editorShareMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "editorShareMenuItem")
    static let editorHistoryMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "editorHistoryMenuItem")
    static let editorTrashMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "editorTrashMenuItem")
    static let editorPublishMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "editorPublishMenuItem")
    static let editorCollaborateMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "editorCollaborateMenuItem")
}
