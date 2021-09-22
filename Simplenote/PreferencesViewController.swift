import Cocoa

class PreferencesViewController: NSViewController {
    let simperium: Simperium
    let options = Options.shared

    required init?(coder: NSCoder) {
        self.simperium = SimplenoteAppDelegate.shared().simperium
        super.init(coder: coder)
    }

    // MARK: Account Section Properties

    /// Account Email Label
    ///
    @IBOutlet private var emailLabel: NSTextField!

    /// Log Out Button:
    ///
    @IBOutlet private var logOutButton: NSButton!

    /// Delete Account Button
    ///
    @IBOutlet private var deleteAccountButton: NSButton!

    // MARK: Note List Appearence Section Properties

    /// Note Sort Order Title
    ///
    @IBOutlet private var noteSortOrderLabel: NSTextField!

    /// Note Line Length Title
    ///
    @IBOutlet private var noteLineLengthLabel: NSTextField!

    /// Note Sort Order Pop Up Button
    ///
    @IBOutlet private var sortOrderPopUp: NSPopUpButton!

    /// Line Length Full Radio Button
    ///
    @IBOutlet private var lineLengthFullRadio: NSButton!

    /// Line Length Narrow Radio Button
    ///
    @IBOutlet private var lineLengthNarrowRadio: NSButton!

    /// Condensed Note List Checkbox
    ///
    @IBOutlet private var condensedNoteListCheckbox: NSButton!

    /// Sort Tags Alphabetically Checkbox
    ///
    @IBOutlet private var sortTagsAlphabeticallyCheckbox: NSButton!

    // MARK: Theme Section Properties

    /// Theme Title Label
    ///
    @IBOutlet private var themeLabel: NSTextField!

    /// Theme Pop Up Button
    ///
    @IBOutlet private var themePopUp: NSPopUpButton!

    // MARK: Text Size Section Properties

    /// Text Size Title Label
    ///
    @IBOutlet private var textSizeLabel: NSTextField!

    /// Text Size Slider
    ///
    @IBOutlet private var textSizeSlider: NSSlider!

    // MARK: Analytics Section Properties

    /// Share Analytics Checkbox
    ///
    @IBOutlet private var shareAnalyticsCheckbox: NSButton!

    /// Analytics Description Label
    ///
    @IBOutlet private var analyticsDescrpitionLabel: NSTextField!

    // MARK: About Simplenote Section Properties

    /// About Simplenote Button
    ///
    @IBOutlet private var aboutSimplenoteButton: NSButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSortModeFields()
        refreshFields()
    }

    private func refreshFields() {
        emailLabel.stringValue = simperium.user?.email ?? ""

        updateSelectedSortMode()
        updateLineLength()

    }

    private func setupSortModeFields() {
        let menuItems: [NSMenuItem] = SortMode.allCases.map { mode in
            let item = NSMenuItem()
            item.title = mode.description
            item.identifier = mode.noteListInterfaceID
            return item
        }
        
        menuItems.forEach({ sortOrderPopUp.menu?.addItem($0) })
    }

    private func updateSelectedSortMode() {
        let sortMode = options.notesListSortMode
        sortOrderPopUp.selectItem(withTitle: sortMode.description)
    }

    private func updateLineLength() {
        if options.editorFullWidth {
            lineLengthFullRadio.state = .on
        } else {
            lineLengthNarrowRadio.state = .on
        }
    }

    // MARK: Account Settings

    @IBAction private func logOutWasPressed(_ sender: Any) {
        let appDelegate = SimplenoteAppDelegate.shared()

        if !StatusChecker.hasUnsentChanges(simperium) {
            appDelegate.signOut()
            self.view.window?.close()
            return
        }

        let alert = NSAlert(messageText: Constants.unsyncedNotesAlertTitle, informativeText: Constants.unsyncedNotesMessage)
        alert.addButton(withTitle: Constants.deleteNotesButton)
        alert.addButton(withTitle: Constants.cancelButton)
        alert.addButton(withTitle: Constants.visitWebButton)
        alert.alertStyle = .critical

        alert.beginSheetModal(for: appDelegate.window) { result in
            switch result {
            case .alertFirstButtonReturn:
                appDelegate.signOut()
            case .alertThirdButtonReturn:
                let url = URL(string: SimplenoteConstants.currentEngineBaseURL as String)!
                NSWorkspace.shared.open(url)
            default:
                break
            }
            self.view.window?.close()
        }

    }

    @IBAction private func deleteAccountWasPressed(_ sender: Any) {
        guard let user = simperium.user else {
            return
        }

        let appDelegate = SimplenoteAppDelegate.shared()

        SPTracker.trackDeleteAccountButttonTapped()
        appDelegate.accountDeletionController?.requestAccountDeletion(for: user, with: appDelegate.window)

        self.view.window?.close()
    }

    // MARK: NoNote List Appearence Settings

    @IBAction private func noteSortOrderWasPressed(_ sender: Any) {
        guard let menu = sender as? NSPopUpButton, let identifier = menu.selectedItem?.identifier, let newMode = SortMode(noteListInterfaceID: identifier) else {
            return
        }

        Options.shared.notesListSortMode = newMode
        SPTracker.trackSettingsNoteListSortMode(newMode.description)
    }

    @IBAction private func noteLineLengthSwitched(_ sender: Any) {
        guard let item = sender as? NSButton else {
            return
        }

        let isFullOn = item.identifier == NSUserInterfaceItemIdentifier.lineFullButton
        Options.shared.editorFullWidth = isFullOn
    }

    @IBAction private func condensedNoteListPressed(_ sender: Any) {
        guard let item = sender as? NSButton else {
            return
        }

        let isCondensedOn = item.identifier == NSUserInterfaceItemIdentifier.noteDisplayCondensedMenuItem
        Options.shared.notesListCondensed = isCondensedOn
        SPTracker.trackSettingsListCondensedEnabled(isCondensedOn)
    }

    @IBAction private func sortTagsAlphabeticallyPressed(_ sender: Any) {
    }

    // MARK: Theme Settings

    @IBAction private func themeWasPressed(_ sender: Any) {
    }

    // MARK: Analytics Settings

    @IBAction private func shareAnalyticsWasPressed(_ sender: Any) {
    }

    // MARK: About Section

    @IBAction private func aboutWasPressed(_ sender: Any) {
    }
    
}

private struct Constants {
    static let deleteNotesButton = NSLocalizedString("Delete Notes", comment: "Delete notes and sign out of the app")
    static let cancelButton = NSLocalizedString("Cancel", comment: "Cancel the action")
    static let visitWebButton = NSLocalizedString("Visit Web App", comment: "Visit app.simplenote.com in the browser")
    static let unsyncedNotesAlertTitle = NSLocalizedString("Unsynced Notes Detected", comment: "Alert title displayed in when an account has unsynced notes")
    static let unsyncedNotesMessage = NSLocalizedString("Signing out will delete any unsynced notes. Check your connection and verify your synced notes by signing in to the Web App.", comment: "Alert message displayed when an account has unsynced notes")
}
