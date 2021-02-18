import Cocoa

// MARK: - SearchMatchesBarViewController
//
class SearchMatchesBarViewController: NSViewController {

    @IBOutlet private weak var textLabel: NSTextField!
    @IBOutlet private weak var navigationControl: NSSegmentedControl!
    @IBOutlet private weak var doneButton: NSButton! {
        didSet {
            doneButton.title = Localization.doneButton
        }
    }

    private var total: Int = 0

    ///
    private var current: Int = Constants.defaultCurrentValue {
        didSet {
            if oldValue != current, current >= 0 {
                onChange?(current)
            }

            update()
        }
    }

    private var onChange: ((_ current: Int) -> Void)?

    /// Callback will be invoked when user presses "done" button
    ///
    var onCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStyle()
        update()
    }

    /// Setup with total number of matches and "on change" callback
    ///
    func setup(with total: Int, onChange: @escaping (_ current: Int) -> Void) {
        self.onChange = onChange
        self.total = total
        current = Constants.defaultCurrentValue
    }

    private func update() {
        textLabel.stringValue = Localization.matches(with: total)

        navigationControl.setEnabled(current - 1 >= 0 && total > 0, forSegment: Constants.backButtonIndex)
        navigationControl.setEnabled(current + 1 < total && total > 0, forSegment: Constants.forwardButtonIndex)
    }
}


// MARK: - Style
//
extension SearchMatchesBarViewController {
    func refreshStyle() {
        textLabel.textColor = .simplenoteSecondaryTextColor
        doneButton.contentTintColor = .simplenoteActionButtonTintColor
    }
}


// MARK: - Actions
//
private extension SearchMatchesBarViewController {
    @IBAction func handlePressOnDoneButton(_ sender: Any) {
        onCompletion?()
    }

    @IBAction func handlePressOnNavigationControl(_ sender: Any) {
        var newCurrent = current
        if navigationControl.selectedSegment == Constants.backButtonIndex {
            newCurrent -= 1
        } else {
            newCurrent += 1
        }

        newCurrent = min(newCurrent, total - 1)
        newCurrent = max(newCurrent, 0)

        current = newCurrent
    }
}


// MARK: - Constants
//
private struct Constants {
    static let backButtonIndex = 0
    static let forwardButtonIndex = 1

    /// We use -1 so that we can navigate to the first match. User presses ">", we go from -1 to 0 and 0 is the index of the first match.
    static let defaultCurrentValue = -1
}


// MARK: - Localization
//
private struct Localization {
    static let doneButton = NSLocalizedString("Done", comment: "Done button on Search Matches bar")

    static private let matchesSingular = NSLocalizedString("%1$d match", comment: "Number of matches shown on Search Matches bar when the amount is 1. Parameters: %1$d - amount")
    static private let matchesPlural = NSLocalizedString("%1$d matches", comment: "Number of matches shown on Search Matches bar when the amount is not 1. Parameters: %1$d - amount")

    static func matches(with value: Int) -> String {
        let template = value == 1 ? matchesSingular : matchesPlural

        return String(format: template, value)
    }
}
