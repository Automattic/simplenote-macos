import Foundation


// MARK: - Private Helpers
//
extension NoteEditorViewController {

    /// Indicates if there's a Note onScreen
    ///
    var isDisplayingNote: Bool {
        note != nil
    }

    /// Indicates if the current document is expected to support Markdown
    ///
    var isMarkdownEnabled: Bool {
        note?.markdown == true && note?.deleted == false
    }

    /// Indicates if the Markdown Preview UI is active
    ///
    var isDisplayingMarkdown: Bool {
        markdownView?.isHidden == false
    }

    /// Indicates if the current document can be shared
    ///
    var isShareEnabled: Bool {
        note?.content?.isEmpty == false
    }

    /// Indicates if there are multiple selected notes
    ///
    var isSelectingMultipleNotes: Bool {
        guard let selection = selectedNotes else {
            return false
        }

        return selection.count > 1
    }


    /// Refreshes the Editor's Inner State
    ///
    @objc
    func refreshEditorActions() {
        noteEditor.isEditable = isDisplayingNote && !viewingTrash
        noteEditor.isSelectable = isDisplayingNote && !viewingTrash
        noteEditor.isHidden = isDisplayingMarkdown
    }

    /// Refreshes the Toolbar's Inner State
    ///
    @objc
    func refreshToolbarActions() {
        toolbarView.isDisplayingNote = isDisplayingNote
        toolbarView.isDisplayingMarkdown = isDisplayingMarkdown

        toolbarView.isMarkdownEnabled = isMarkdownEnabled
        toolbarView.isSelectingMultipleNotes = isSelectingMultipleNotes
        toolbarView.isShareEnabled = isShareEnabled
        toolbarView.isViewingTrash = viewingTrash

    }
}
