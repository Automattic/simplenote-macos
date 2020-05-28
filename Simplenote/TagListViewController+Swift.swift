import Foundation


// MARK: - NSTableViewDelegate Helpers
//
extension TagListViewController {

    /// Returns a PaddingTableCellView instance, meant to be used as Tags List Header
    /// -   Note:
    ///     Why the universe has to be SO complicated?
    ///
    /// -   Note:
    ///     When entering / leaving fullscreen, we need to adjust the ScrollView's contentInsets: the titlebar disappears, or shows up, right?
    ///     For that reason, we really need to enable `NSScrollView.automaticallyAdjustsContentInsets`, since handling is for free.
    ///     Problem is that macOS does not provide a mechanism to provide `Additional Content Insets` (iOS does!).
    ///     And yes, you guessed right. Workaround: inject an `Empty / Padding Cell`.
    ///
    @objc
    func paddingTableViewCell() -> PaddingTableCellView {
        return tableView.makeTableViewCell(ofType: PaddingTableCellView.self)
    }

    /// Returns a HeaderTableCellView instance, meant to be used as Tags List Header
    ///
    @objc
    func tagHeaderTableViewCell() -> HeaderTableCellView {
        let headerView = tableView.makeTableViewCell(ofType: HeaderTableCellView.self)
        headerView.textField?.stringValue = NSLocalizedString("Tags", comment: "Tags Section Name").uppercased()
        return headerView
    }

    /// Returns a TagTableCellView instance, initialized to be used as All Notes Row
    ///
    @objc
    func allNotesTableViewCell() -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.iconImageView.image = NSImage(named: .allNotes)
        tagView.iconImageView.isHidden = false
        tagView.nameTextField.stringValue = NSLocalizedString("All Notes", comment: "Title of the view that displays all your notes")

        return tagView
    }

    /// Returns a TagTableCellView instance, initialized to be used as Trash Row
    ///
    @objc
    func trashTableViewCell() -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.iconImageView.image = NSImage(named: .trash)
        tagView.iconImageView.isHidden = false
        tagView.nameTextField.stringValue = NSLocalizedString("Trash", comment: "Title of the view that displays all your deleted notes")

        return tagView
    }

    /// Returns a TagTableCellView instance, initialized to render a specified Tag
    ///
    @objc(tagTableViewCellForTag:)
    func tagTableViewCell(for tag: Tag) -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.nameTextField.delegate = self
        tagView.nameTextField.isEditable = true
        tagView.nameTextField.stringValue = tag.name

        return tagView
    }
}


// MARK: - SPTextFieldDelegate
//
extension TagListViewController: SPTextFieldDelegate {

    func controlAcceptsFirstResponder(_ control: NSControl) -> Bool {
        !menuShowing
    }
}
