import Foundation


// MARK: - Private Helpers
//
extension NoteEditorViewController {

    /// Ensures only the actions that are valid can be performed
    ///
    @objc
    func refreshEnabledActions() {
        noteEditor.isEditable = !viewingTrash
        noteEditor.isSelectable = !viewingTrash
    }
}
