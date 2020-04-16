import Foundation


// MARK: - NSTableViewDelegate Helpers
//
extension TagListViewController {

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
        tagView.imageView?.image = NSImage(named: .allNotes)
        tagView.imageView?.isHidden = false
        tagView.textField?.stringValue = NSLocalizedString("All Notes", comment: "Title of the view that displays all your notes")

        return tagView
    }

    /// Returns a TagTableCellView instance, initialized to be used as Trash Row
    ///
    @objc
    func trashTableViewCell() -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.imageView?.image = NSImage(named: .trash)
        tagView.imageView?.isHidden = false
        tagView.textField?.stringValue = NSLocalizedString("Trash", comment: "Title of the view that displays all your deleted notes")

        return tagView
    }

    /// Returns a TagTableCellView instance, initialized to render a specified Tag
    ///
    @objc(tagTableViewCellForTag:)
    func tagTableViewCell(for tag: Tag) -> TagTableCellView {
        let tagView = tableView.makeTableViewCell(ofType: TagTableCellView.self)
        tagView.imageView?.isHidden = true
        tagView.textField?.delegate = self
        tagView.textField?.stringValue = tag.name

        return tagView
    }
}
