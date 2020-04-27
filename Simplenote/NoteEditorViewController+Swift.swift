import Foundation


// MARK: - Private Helpers
//
extension NoteEditorViewController {

    /// Indicates if there's a Note onScreen
    ///
    var displayingNote: Bool {
        note != nil
    }

    /// Indicates if the Markdown Preview UI is active
    ///
    var displayingMarkdown: Bool {
        markdownView?.isHidden == false
    }

    /// Indicates if the current document is expected to support Markdown
    ///
    var isMarkdownAllowed: Bool {
        note?.markdown == true
    }

    /// Indicates if the current document can be shared
    ///
    var isShareAllowed: Bool {
        note?.content?.isEmpty == false
    }

    /// Indicates if there are multiple selected notes
    ///
    var multipleSelection: Bool {
        guard let selection = selectedNotes else {
            return false
        }

        return selection.count > 1
    }


    /// Refreshes the Editor's Inner State
    ///
    @objc
    func refreshEditorActions() {
        noteEditor.isEditable = displayingNote && !viewingTrash
        noteEditor.isSelectable = displayingNote && !viewingTrash
        noteEditor.isHidden = displayingMarkdown
    }

    /// Refreshes the Toolbar's Inner State
    ///
    @objc
    func refreshToolbarActions() {
        toolbarView.displayingNote = displayingNote
        toolbarView.multipleSelection = multipleSelection
        toolbarView.displayingTrash = viewingTrash
        toolbarView.displayingMarkdown = displayingMarkdown
        toolbarView.isMarkdownAllowed = isMarkdownAllowed
        toolbarView.isShareAllowed = isShareAllowed
    }
}
