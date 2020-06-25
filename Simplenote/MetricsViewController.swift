import Foundation
import AppKit


// MARK: - MetricsViewController
//
class MetricsViewController: NSViewController {

    /// Modified: Left Text Label
    ///
    @IBOutlet private(set) var modifiedTextLabel: NSTextField!

    /// Modified: Note Metrics!
    ///
    @IBOutlet private(set) var modifiedDetailsLabel: NSTextField!

    /// Created: Left Text Label
    ///
    @IBOutlet private(set) var createdTextLabel: NSTextField!

    /// Created: Note Metrics!
    ///
    @IBOutlet private(set) var createdDetailsLabel: NSTextField!

    /// Words: Left Text Label
    ///
    @IBOutlet private(set) var wordsTextLabel: NSTextField!

    /// Words: Note Metrics!
    ///
    @IBOutlet private(set) var wordsDetailsLabel: NSTextField!

    /// Characters: Left Text Label
    ///
    @IBOutlet private(set) var charsTextLabel: NSTextField!

    /// Characters: Note Metrics!
    ///
    @IBOutlet private(set) var charsDetailsLabel: NSTextField!


    // MARK: - Overridden Methdods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextLabels()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        setupWindow()
    }
}


// MARK: - Private
//
private extension MetricsViewController {

    func setupTextLabels() {
        modifiedTextLabel.stringValue = NSLocalizedString("Modified", comment: "")
        createdTextLabel.stringValue = NSLocalizedString("Created", comment: "")
        wordsTextLabel.stringValue = NSLocalizedString("Words", comment: "")
        charsTextLabel.stringValue = NSLocalizedString("Characters", comment: "")
    }

    func setupWindow() {
        view.window?.title = NSLocalizedString("Information", comment: "")
    }
}
