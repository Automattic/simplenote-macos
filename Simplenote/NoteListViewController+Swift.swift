import Foundation


// MARK: - Private Helpers
//
extension NoteListViewController {

    /// Ensures only the actions that are valid can be performed
    ///
    @objc
    func refreshEnabledActions() {
        addNoteButton.isEnabled = !viewingTrash
    }
}
