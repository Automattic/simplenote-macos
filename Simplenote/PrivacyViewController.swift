//
//  PrivacyViewController.swift
//  Simplenote
//

import Cocoa


/// Displays the Privacy Settings
///
class PrivacyViewController: NSViewController {

    /// Share Button
    ///
    @IBOutlet private var shareEnabledButton: NSButton!

    /// About Legend
    ///
    @IBOutlet private var cookiePolicyTextField: SPAboutTextField!

    /// About Arrow Image
    ///
    @IBOutlet private var cookiePolicyImageView: NSImageView!

    /// About Legend
    ///
    @IBOutlet private var privacyPolicyTextField: SPAboutTextField!

    /// About Arrow Image
    ///
    @IBOutlet private var privacyPolicyImageView: NSImageView!

    /// About Legend
    ///
    @IBOutlet private var trackingTextField: SPAboutTextField!

    /// About Arrow Image
    ///
    @IBOutlet private var trackingImageView: NSImageView!


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
        refreshInterface()
        setupTextFields()
        setupGestureRecognizers()
        startListeningForNotifications()
    }


    /// Updates the Share Button state
    ///
    private func refreshInterface() {
        shareEnabledButton.state = isAnalyticsEnabled ? .on : .off
    }

    /// Initializes the About TextField / ImageView Click Recognizers
    ///
    private func setupGestureRecognizers() {
        let cookieFieldGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(cookiePolicyWasPressed))
        cookiePolicyTextField.addGestureRecognizer(cookieFieldGestureRecognizer)

        let cookieImageGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(cookiePolicyWasPressed))
        cookiePolicyImageView.addGestureRecognizer(cookieImageGestureRecognizer)

        let privacyFieldGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(privacyPolicyWasPresed))
        privacyPolicyTextField.addGestureRecognizer(privacyFieldGestureRecognizer)

        let privacyImageGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(privacyPolicyWasPresed))
        privacyPolicyImageView.addGestureRecognizer(privacyImageGestureRecognizer)

        let trackingFieldGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(trackingWasPresed))
        trackingTextField.addGestureRecognizer(trackingFieldGestureRecognizer)

        let trackingImageGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(trackingWasPresed))
        trackingImageView.addGestureRecognizer(trackingImageGestureRecognizer)
    }

    /// Sets up the TextField's Text
    ///
    private func setupTextFields() {
        cookiePolicyTextField.stringValue = NSLocalizedString("Help us improve Simplenote by sharing usage data with our analytics tool.", comment: "Analytics Legend")
        privacyPolicyTextField.stringValue = NSLocalizedString("This information helps us improve our products, make marketing more relevant to you, and more as detailed in our privacy policy.", comment: "Privacy Policy Legend")
        trackingTextField.stringValue = NSLocalizedString("We use other tracking tools, including some from third parties. Read about these and how to control them.", comment: "Tracking Legend")
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
        let targetURL = URL(string: SPAutomatticCookiePolicyURL)!
        NSWorkspace.shared.open(targetURL)
    }

    /// Opens the Privacy Policy URL
    ///
    @IBAction func privacyPolicyWasPresed(sender: Any) {
        let targetURL = URL(string: SPAutomatticPrivacyPolicyURL)!
        NSWorkspace.shared.open(targetURL)
    }

    /// Opens the Tracking Policy URL. Which is... well, the same as the Cookie Policy. At least for now!
    ///
    @IBAction func trackingWasPresed(sender: Any) {
        cookiePolicyWasPressed(sender: sender)
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
