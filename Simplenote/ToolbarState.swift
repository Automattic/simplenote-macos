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

    /// Indicates if the current document supports Markdown
    ///
    let isMarkdownEnabled: Bool

    /// Indicates if the current document supports Sharing
    ///
    let isShareEnabled: Bool

    /// Indicates if there are multiple selected documents
    ///
    let isSelectingMultipleNotes: Bool

    /// Indicates if Trash is on Screen
    ///
    let isViewingTrash: Bool


    // MARK: - UI Initialization Helpers

    var isActionButtonEnabled: Bool {
        (isDisplayingNote || isSelectingMultipleNotes) && !isViewingTrash
    }

    var isActionButtonHidden: Bool {
        isViewingTrash
    }

    var isHistoryActionEnabled: Bool {
        isDisplayingNote && !isDisplayingMarkdown
    }

    var isHistoryActionHidden: Bool {
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

    var isShareActionEnabled: Bool {
        isShareEnabled
    }

    var isShareActionHidden: Bool {
        isViewingTrash
    }

    var isTrashActionEnabled: Bool {
        isDisplayingNote || isSelectingMultipleNotes
    }

    var isTrashActionHidden: Bool {
        isViewingTrash
    }

    var previewActionImage: NSImage? {
        let name: NSImage.Name = isDisplayingMarkdown ? .previewOn : .previewOff
        return NSImage(named: name)
    }
}


// MARK: - Helpers
//
extension ToolbarState {

    static var `default`: ToolbarState {
        ToolbarState(isDisplayingNote: false,
                     isDisplayingMarkdown: false,
                     isMarkdownEnabled: false,
                     isShareEnabled: false,
                     isSelectingMultipleNotes: false,
                     isViewingTrash: false)
    }
}
