import Foundation

// MARK: - ToolbarState: Encapsulates all of the logic that determines the inner Toolbar State
//
struct ToolbarState {

    /// Indicates if a Note is onScreen
    ///
    let isDisplayingNote: Bool

    /// Indicates if we're rendering Markdown
    ///
    let isDisplayingMarkdown: Bool

    /// Indicates if the Editor is the First Responder
    ///
    let isEditorActive: Bool

    /// Indicates if the current document supports Markdown
    ///
    let isMarkdownEnabled: Bool

    /// Indicates if there are multiple selected documents
    ///
    let isSelectingMultipleNotes: Bool

    /// Indicates if Trash is on Screen
    ///
    let isViewingTrash: Bool
}

// MARK: - Derived Properties
//
extension ToolbarState {

    var isChecklistsButtonEnabled: Bool {
        isDisplayingNote && isEditorActive
    }

    var isChecklistsButtonHidden: Bool {
        (isViewingTrash || isSelectingMultipleNotes)
    }

    var isMetricsButtonEnabled: Bool {
        (isDisplayingNote || isSelectingMultipleNotes)
    }

    var isMetricsButtonHidden: Bool {
        isViewingTrash
    }

    var isMoreButtonEnabled: Bool {
        (isDisplayingNote || isSelectingMultipleNotes)
    }

    var isMoreButtonHidden: Bool {
        isViewingTrash
    }

    var isPreviewActionHidden: Bool {
        !isMarkdownEnabled || isViewingTrash
    }

    var isRestoreActionEnabled: Bool {
        isDisplayingNote
    }

    var isRestoreActionHidden: Bool {
        !isViewingTrash
    }

    var previewActionImage: NSImage? {
        let name: NSImage.Name = isDisplayingMarkdown ? .previewOff : .previewOn
        return NSImage(named: name)
    }
}

// MARK: - Default State
//
extension ToolbarState {

    static var `default`: ToolbarState {
        ToolbarState(isDisplayingNote: false,
                     isDisplayingMarkdown: false,
                     isEditorActive: false,
                     isMarkdownEnabled: false,
                     isSelectingMultipleNotes: false,
                     isViewingTrash: false)
    }
}
