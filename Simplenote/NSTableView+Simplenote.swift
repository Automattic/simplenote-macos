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
    ///
    func reloadAndPreserveSelection() {
        let previouslySelectedRow = self.selectedRow
        reloadData()

        // Out of Bounds failsafe. Always!
        guard previouslySelectedRow < numberOfRows else {
            return
        }

        selectRowIndexes(IndexSet(integer: previouslySelectedRow), byExtendingSelection: false)
    }
}
