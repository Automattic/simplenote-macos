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
    @IBOutlet private var aboutTextField: SPAboutTextField!

    /// About Arrow Image
    ///
    @IBOutlet private var aboutImageView: NSImageView!

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
        let textfieldRecognizer = NSClickGestureRecognizer(target: self, action: #selector(learnMoreWasPressed))
        aboutTextField.addGestureRecognizer(textfieldRecognizer)

        let checkboxRecognizer = NSClickGestureRecognizer(target: self, action: #selector(learnMoreWasPressed))
        aboutImageView.addGestureRecognizer(checkboxRecognizer)
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

    /// Opens the Learn More URL
    ///
    @IBAction func learnMoreWasPressed(sender: Any) {
        NSWorkspace.shared.open(URL(string: SPAutomatticAnalyticLearnMoreURL)!)
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
