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
        searchField.placeholderAttributedString = searchFieldPlaceholderString
        statusField.textColor = .simplenoteSecondaryTextColor

        reloadDataAndPreserveSelection()
    }
}


// MARK: - Helpers
//
private extension NoteListViewController {

    var searchFieldPlaceholderString: NSAttributedString {
        let text = NSLocalizedString("Search", comment: "Search Field Placeholder")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.simplenoteSecondaryTextColor,
            .font: NSFont.simplenotePopoverTextFont
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
}
