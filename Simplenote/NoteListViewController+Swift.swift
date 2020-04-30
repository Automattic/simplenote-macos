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

    /// Refreshes the receiver's style
    ///
    @objc
    func applyStyle() {
        let name: NSAppearance.Name = SPUserInterface.isDark ? .vibrantDark : .aqua

        addNoteButton.tintImage(color: .simplenoteActionButtonTintColor)
        searchField.appearance = NSAppearance(named: name)
        searchField.textColor = .simplenoteTextColor
        statusField.textColor = .simplenoteSecondaryTextColor

        reloadDataAndPreserveSelection()
    }
}
