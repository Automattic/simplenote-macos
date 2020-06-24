import Foundation


// MARK: - Interface Initialization
//
extension TagListViewController {

    @objc
    func refreshExtendedContentInsets() {
        clipView.extendedContentInsets.top = Settings.extendedTopInset
    }
}




// MARK: - Convienience API(s)
//
extension TagListViewController {

    /// Returns the `TagListRow` entity at the specified Index
    /// - Note: YES we perform Bounds Check, just in order to avoid guarding for `NSNotFound` all over the place.
    ///
    func rowAtIndex(_ index: Int) -> TagListRow? {
        guard index >= .zero && index < state.rows.count else {
            return nil
        }

        return state.rows[index]
    }

    /// Returns the location of the `All Notes` row.
    /// - Note: This row is mandatory, it's expected to *always* be present.
    ///
    @objc
    var indexOfAllNotes: IndexSet {
        guard let index = state.rows.firstIndex(of: .allNotes) else {
            fatalError()
        }

        return IndexSet(integer: index)
    }

    /// Returns the Index of the tag with the specified Name (If any!)
    ///
    @objc
    func indexOfTag(name: String) -> IndexSet? {
        for (index, row) in state.rows.enumerated() {
            guard case let .tag(tag) = row, tag.name == name else {
                continue
            }

            return IndexSet(integer: index)
        }

        return nil
    }

    /// Returns the location of the first Tag Row.
    /// - Note: This API should return an optional. But because of ObjC bridging, we simply refuse to use NSNotFound as a sentinel.
    ///
    @objc
    var numberOfFirstTagRow: Int {
        for (index, row) in state.rows.enumerated() {
            guard case .tag = row else {
                continue
            }

            return index
        }

        return .zero
    }

    /// Returns the Tag Row at the specified location
    ///
    @objc
    func tag(atIndex index: Int) -> Tag? {
        guard case let .tag(tag) = rowAtIndex(index) else {
            return nil
        }

        return tag
    }
}


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


// MARK: - Settings!
//
private enum Settings {
    static let extendedTopInset = CGFloat(48)
}


// MARK: - List Row
//
enum TagListRow: Equatable {
    case allNotes
    case trash
    case header
    case tag(tag: Tag)
    case untagged
}


// MARK: - List State: Allows us to wrap a native Swift type into an ObjC Property
//         TODO: Let's remove this the second TagListController is Swift native!
//
@objc
class TagListState: NSObject {
    let rows: [TagListRow]

    init(rows: [TagListRow]) {
        self.rows = rows
    }
}
