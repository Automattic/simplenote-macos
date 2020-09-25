import Foundation
import AppKit


// MARK: - InterlinkWindowController
//
class InterlinkWindowController: NSWindowController {

    private var interlinkViewController: InterlinkViewController? {
        contentViewController as? InterlinkViewController
    }

    func refreshSuggestions(for keyword: String) {
        // TODO!
    }
}
