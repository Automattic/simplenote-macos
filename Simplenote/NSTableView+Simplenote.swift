import Foundation


// MARK: - NSTableView+Simplenote
//
extension NSTableView {

    /// Returns a (new) instance of the cell of a given type.
    /// Note: This method is expected to halt execution, on error.
    ///
    func makeTableViewCell<T: NSTableCellView>(ofType type: T.Type) -> T {
        guard let target = makeView(withIdentifier: T.reuseIdentifier, owner: self) as? T else {
            fatalError()
        }

        return target
    }

    /// Reloads the selected row in (all) of the available columns
    ///
    @objc
    func reloadSelectedRow() {
        guard selectedRow != -1 else {
            return
        }

        let allColumns = IndexSet(integersIn: .zero ..< numberOfColumns)
        reloadData(forRowIndexes: selectedRowIndexes, columnIndexes: allColumns)
    }

    /// Reloads the receiver's data and preserves the selected row
    /// - Note:If the previously selected row is no more, we'll fallback to selecting the last row
    ///
    func reloadAndPreserveSelection() {
        var previouslySelectedRow = selectedRow
        reloadData()

        if previouslySelectedRow >= numberOfRows {
            previouslySelectedRow = numberOfRows - 1
        }

        selectRowIndexes(IndexSet(integer: previouslySelectedRow), byExtendingSelection: false)
    }

    /// Reloads the receiver's data and resets the selected row
    ///
    func reloadDataAndResetSelection() {
        deselectAll(nil)
        scrollRowToVisible(.zero)
        reloadData()
    }

    /// Whenever we're compiling Simplenote in macOS +11 **AND** we're running the binary in macOS +11, we'll make sure the
    /// receiver's style is set to Full Width.
    ///
    func ensureStyleIsFullWidth() {
// BigSur compile-time guard
#if canImport(WidgetKit)
        guard #available(macOS 11, *) else {
            return
        }

        style = .fullWidth
#endif
    }
}
