import Foundation
import AppKit


// MARK: - InterlinkViewController
//
class InterlinkViewController: NSViewController {

    /// Background
    ///
    @IBOutlet private var backgroundView: BackgroundView!

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: NSTableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
    }
}


// MARK: - Setup!
//
private extension InterlinkViewController {

    func setupBackground() {
        backgroundView.fillColor = .simplenoteBackgroundColor
        tableView.backgroundColor = .clear
    }
}
}
