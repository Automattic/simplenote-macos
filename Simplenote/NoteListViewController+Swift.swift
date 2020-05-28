import Foundation


// MARK: - Private Helpers
//
extension NoteListViewController {

    /// Setup: SearchBar
    ///
    @objc
    func setupSearchBar() {
        searchField.centersPlaceholder = false
    }

    /// Setup: Top Divider
    ///
    @objc
    func setupTopDivider() {
        topDividerView.drawsBottomBorder = true
    }

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
        backgroundView.fillColor = .simplenoteSecondaryBackgroundColor
        topDividerView.borderColor = .simplenoteDividerColor
        addNoteButton.tintImage(color: .simplenoteActionButtonTintColor)
        searchField.textColor = .simplenoteTextColor
        searchField.placeholderAttributedString = searchFieldPlaceholderString
        statusField.textColor = .simplenoteSecondaryTextColor
        reloadDataAndPreserveSelection()

        // Legacy Support: High Sierra
        if #available(macOS 10.14, *) {
            return
        }

        let name: NSAppearance.Name = SPUserInterface.isDark ? .vibrantDark : .aqua
        searchField.appearance = NSAppearance(named: name)
    }
}


// MARK: - Autolayout FTW
//
extension NoteListViewController {

    open override func updateViewConstraints() {
        if mustUpdateSearchViewConstraint {
            updateSearchViewTopConstraint()
        }

        super.updateViewConstraints()
    }

    var mustUpdateSearchViewConstraint: Bool {
        // Why check `.isActive`?:
        // Because we're in a midway refactor. The NoteList.view is, initially, embedded elsewhere.
        // TODO: Simplify this check, the second MainMenu.xib is cleaned up!
        searchViewTopConstraint == nil || searchViewTopConstraint?.isActive == false
    }

    func updateSearchViewTopConstraint() {
        guard let layoutGuide = searchView.window?.contentLayoutGuide as? NSLayoutGuide else {
            return
        }

        searchViewTopConstraint = searchView.topAnchor.constraint(equalTo: layoutGuide.topAnchor)
        searchViewTopConstraint.isActive = true
    }
}


// MARK: - Helpers
//
private extension NoteListViewController {

    var searchFieldPlaceholderString: NSAttributedString {
        let text = NSLocalizedString("Search", comment: "Search Field Placeholder")
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.simplenoteSecondaryTextColor,
            .font: NSFont.simplenoteSecondaryTextFont
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
}


// MARK: - NSTableViewDelegate Helpers
//
extension NoteListViewController {

    @objc(noteTableViewCellForNote:)
    func noteTableViewCell(for note: Note) -> NoteTableCellView {
        note.ensurePreviewStringsAreAvailable()

        let noteView = tableView.makeTableViewCell(ofType: NoteTableCellView.self)

        noteView.displaysPinnedIndicator = note.pinned
        noteView.displaysSharedIndicator = note.published
        noteView.title = note.titlePreview
        noteView.body = note.bodyPreview
        noteView.rendersInCondensedMode = Options.shared.notesListCondensed

        noteView.refreshAttributedStrings()

        return noteView
    }
}
