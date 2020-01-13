import Cocoa


/// Displays the Privacy Settings
///
class PrivacyViewController: NSViewController {

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

    /// Indicates if Analytics are Enabled
    ///
    private var isAnalyticsEnabled: Bool {
        guard let simperium = SimplenoteAppDelegate.shared()?.simperium, let preferences = simperium.preferencesObject() else {
            return false
        }

        return preferences.analytics_enabled?.boolValue == true
    }

    /// Deinitializer!
    ///
    deinit {
        stopListeningForNotifications()
    }


    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        refreshInterface()
        startListeningForNotifications()
    }

    /// Sets up all of the TextFields
    ///
    private func configureTextFields() {
        titleTextField.stringValue = NSLocalizedString("Privacy Policy", comment: "Privacy Policy's Title")
        shareTextField.stringValue = NSLocalizedString("Collect Information", comment: "Analytics Toggle Text")
        cookiePolicyTextField.stringValue = NSLocalizedString("Share information with our analytics tool about your use of services while logged into your Simplenote.com account.", comment: "Cookie Policy Legend")
        privacyTextField.stringValue = NSLocalizedString("This information helps us improve our products, make marketing to you more relevant, personalize your Simplenote.com experience, and more as detailed in our privacy policy.", comment: "Privacy Policy")
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
        guard let simperium = SimplenoteAppDelegate.shared()?.simperium, let preferences = simperium.preferencesObject() else {
            return
        }

        let isEnabled = shareEnabledButton.state == .on
        preferences.analytics_enabled = NSNumber(booleanLiteral: isEnabled)
        simperium.save()
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


// MARK: - Notification Helpers
//
extension PrivacyViewController {

    /// Starts listening for Privacy Updates
    ///
    private func startListeningForNotifications() {
        let moc = SimplenoteAppDelegate.shared()?.managedObjectContext
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(privacyWasUpdated),
                                               name: .NSManagedObjectContextObjectsDidChange,
                                               object: moc)
    }

    /// Stops listening for Privacy Updates
    ///
    private func stopListeningForNotifications() {
        let moc = SimplenoteAppDelegate.shared()?.managedObjectContext
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: moc)
    }

    /// Whenever the Privacy object is updated in the main MOC, we'll refresh the Interface
    ///
    @objc func privacyWasUpdated(_ notification: Notification) {
        let updated             = notification.userInfo?[NSUpdatedObjectsKey]   as? Set<NSManagedObject> ?? Set()
        let refreshed           = notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> ?? Set()
        let updatedAndRefreshed = updated.union(refreshed)

        guard updatedAndRefreshed.contains(where: { $0 is Preferences }) else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.refreshInterface()
        }
    }
}
