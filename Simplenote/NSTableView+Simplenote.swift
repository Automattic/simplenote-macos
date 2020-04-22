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
}
