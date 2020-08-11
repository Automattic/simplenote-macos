import Foundation


// MARK: - NSSearchField Methods
//
extension NSSearchField {

    func cancelSearch() {
        stringValue = ""

        let searchCell = cell as? NSSearchFieldCell
        searchCell?.cancelButtonCell?.performClick(self)
    }
}
