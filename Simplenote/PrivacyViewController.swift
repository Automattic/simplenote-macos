import Cocoa


/// Displays the Privacy Settings
///
class PrivacyViewController: NSViewController {

    /// Background Box
    ///
    @IBOutlet private var backgroundBox: NSBox!

    /// Title: TextField
    ///
    @IBOutlet private var titleTextField: NSTextField!

    /// Share: TextField
    ///
    @IBOutlet private var shareTextField: NSTextField!

    /// Share: Button
    ///
    @IBOutlet private var shareEnabledButton: NSButton!

    /// Section #1: TextField
    ///
    @IBOutlet private var cookiePolicyTextField: SPAboutTextField!

    /// Section #1: Action Image
    ///
    @IBOutlet private var cookiePolicyImageView: NSImageView!

    /// Section #2: TextField
    ///
    @IBOutlet private var privacyTextField: SPAboutTextField!

    /// Section #2: Action Image
    ///
    @IBOutlet private var privacyImageView: NSImageView!

    /// Dismiss Action
    ///
    @IBOutlet private var dismissButton: NSButton!

    /// Indicates if Analytics are Enabled
    ///
    private var isAnalyticsEnabled: Bool {
        Options.shared.analyticsEnabled
    }


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundBox()
        configureTextFields()
        configureButtons()
        refreshInterface()
    }

    /// Setup: Background
    ///
    private func configureBackgroundBox() {
        backgroundBox.fillColor = .simplenoteBrandColor
    }

    /// Sets up all of the TextFields
    ///
    private func configureTextFields() {
        titleTextField.stringValue = NSLocalizedString("Privacy Policy", comment: "Privacy Policy's Title")
        shareTextField.stringValue = NSLocalizedString("Collect Information", comment: "Analytics Toggle Text")
        cookiePolicyTextField.stringValue = NSLocalizedString("Share information with our analytics tool about your use of services while logged into your Simplenote.com account.", comment: "Cookie Policy Legend")
        privacyTextField.stringValue = NSLocalizedString("This information helps us improve our products, make marketing to you more relevant, personalize your Simplenote.com experience, and more as detailed in our privacy policy.", comment: "Privacy Policy")
    }

    /// Setup: Buttons
    ///
    private func configureButtons() {
        dismissButton.title = NSLocalizedString("Dismiss", comment: "Closes the Privacy View")
    }

    /// Updates the Share Button state
    ///
    private func refreshInterface() {
        shareEnabledButton.state = isAnalyticsEnabled ? .on : .off
    }
}


// MARK: - Actions
//
extension PrivacyViewController {

    /// Toggles the Share Analytics setting
    ///
    @IBAction func checkboxWasPressed(sender: Any) {
        let isEnabled = shareEnabledButton.state == .on
        Options.shared.analyticsEnabled = isEnabled
    }

    /// Opens the Cookie Policy URL
    ///
    @IBAction func cookiePolicyWasPressed(sender: Any) {
        NSWorkspace.shared.open(URL(string: SPAutomatticAnalyticCookiesURL)!)
    }

    /// Opens the Privacy Policy URL
    ///
    @IBAction func privacyPolicyWasPressed(sender: Any) {
        NSWorkspace.shared.open(URL(string: SPAutomatticAnalyticPrivacyURL)!)
    }

    /// Dismisses the associated Window
    ///
    @IBAction func dismissWasPressed(sender: Any) {
        guard let privacyWindow = view.window, let parentWindow = privacyWindow.sheetParent else {
            return
        }

        parentWindow.endSheet(privacyWindow)
    }
}
