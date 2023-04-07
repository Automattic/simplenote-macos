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
    static let systemDuplicateNoteMenuItem  = NSUserInterfaceItemIdentifier(rawValue: "systemDuplicateNoteMenuItem")
    static let systemNewNoteMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "systemNewNoteMenuItem")
    static let systemTrashMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "systemTrashMenuItem")
    static let systemPrintMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "systemPrintMenuItem")

    /// Identifiers: View Menu
    ///
    static let lineNarrowButton             = NSUserInterfaceItemIdentifier(rawValue: "lineNarrowButton")
    static let lineFullButton               = NSUserInterfaceItemIdentifier(rawValue: "lineFullButton")
    static let noteDisplayCondensedButton   = NSUserInterfaceItemIdentifier(rawValue: "noteDisplayCondensedButton")
    static let noteSortAlphaAscMenuItem     = NSUserInterfaceItemIdentifier(rawValue: "noteSortAlphaAscMenuItem")
    static let noteSortAlphaDescMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "noteSortAlphaDescMenuItem")
    static let noteSortCreateNewestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortCreateNewestMenuItem")
    static let noteSortCreateOldestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortCreateOldestMenuItem")
    static let noteSortModifyNewestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortModifyNewestMenuItem")
    static let noteSortModifyOldestMenuItem = NSUserInterfaceItemIdentifier(rawValue: "noteSortModifyOldestMenuItem")
    static let focusMenuItem                = NSUserInterfaceItemIdentifier(rawValue: "focusMenuItem")
    static let sidebarMenuItem              = NSUserInterfaceItemIdentifier(rawValue: "sidebarMenuItem")
    static let statusBarMenuItem            = NSUserInterfaceItemIdentifier(rawValue: "statusBarMenuItem")
    static let toggleMarkdownPreview        = NSUserInterfaceItemIdentifier(rawValue: "toggleMarkdownPreview")

    /// Identifiers: Notes List
    ///
    static let listCopyInterlinkMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "listCopyInterlinkMenuItem")
    static let listDeleteForeverMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "listDeleteForeverMenuItem")
    static let listDuplicateNoteMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "listDuplicateNoteMenuItem")
    static let listPinMenuItem              = NSUserInterfaceItemIdentifier(rawValue: "listPinMenuItem")
    static let listRestoreNoteMenuItem      = NSUserInterfaceItemIdentifier(rawValue: "listRestoreNoteMenuItem")
    static let listTrashNoteMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "listTrashNoteMenuItem")

    /// Identifiers: Editor
    ///
    static let editorPinMenuItem            = NSUserInterfaceItemIdentifier(rawValue: "editorPinMenuItem")
    static let editorChecklistMenuItem      = NSUserInterfaceItemIdentifier(rawValue: "editorChecklistMenuItem")
    static let editorDuplicateNoteMenuItem  = NSUserInterfaceItemIdentifier(rawValue: "editorDuplicateNoteMenuItem")
    static let editorMarkdownMenuItem       = NSUserInterfaceItemIdentifier(rawValue: "editorMarkdownMenuItem")
    static let editorCopyInterlinkMenuItem  = NSUserInterfaceItemIdentifier(rawValue: "editorCopyInterlinkMenuItem")
    static let editorShareMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "editorShareMenuItem")
    static let editorHistoryMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "editorHistoryMenuItem")
    static let editorTrashMenuItem          = NSUserInterfaceItemIdentifier(rawValue: "editorTrashMenuItem")
    static let editorPublishMenuItem        = NSUserInterfaceItemIdentifier(rawValue: "editorPublishMenuItem")
    static let editorCollaborateMenuItem    = NSUserInterfaceItemIdentifier(rawValue: "editorCollaborateMenuItem")
}
