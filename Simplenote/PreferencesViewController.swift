import Cocoa

class PreferencesViewController: NSViewController {
    let simperium = SimplenoteAppDelegate.shared().simperium

    var aboutWindowController: NSWindowController?

    // MARK: Labels
    
    @IBOutlet private var emailLabel: NSTextField!
    @IBOutlet private var accountTitleLabel: NSTextField!
    @IBOutlet private var sortOrderLabel: NSTextField!
    @IBOutlet private var lineLengthLabel: NSTextField!
    @IBOutlet private var themeLabel: NSTextField!
    @IBOutlet private var textSizeLabel: NSTextField!
    @IBOutlet private var littleALabel: NSTextField!
    @IBOutlet private var bigALabel: NSTextField!
    @IBOutlet private var analyticsDescriptionLabel: NSTextField!

    // MARK: Interactive Elements

    @IBOutlet private var deleteAccountButton: NSButton!
    @IBOutlet private var sortOrderPopUp: NSPopUpButton!
    @IBOutlet private var lineLengthFullRadio: NSButton!
    @IBOutlet private var lineLengthNarrowRadio: NSButton!
    @IBOutlet private var condensedNoteListCheckbox: NSButton!
    @IBOutlet private var sortTagsAlphabeticallyCheckbox: NSButton!
    @IBOutlet private var themePopUp: NSPopUpButton!
    @IBOutlet private var textSizeSlider: NSSlider!
    @IBOutlet private var shareAnalyticsCheckbox: NSButton!

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSortModeFields()
        setupThemeFields()
        refreshFields()
        refreshStyle()
    }

    private func refreshFields() {
        emailLabel.stringValue = simperium.user?.email ?? ""

        updateSelectedSortMode()
        updateLineLength()
        condensedNoteListCheckbox.state = Options.shared.notesListCondensed ? .on : .off
        sortTagsAlphabeticallyCheckbox.state = Options.shared.alphabeticallySortTags ? .on : .off

        updateSelectedTheme()

        textSizeSlider.intValue = Int32(Options.shared.fontSize)

        shareAnalyticsCheckbox.state = Options.shared.analyticsEnabled ? .on: .off

    }

    private func refreshStyle() {
        deleteAccountButton.bezelStyle = .roundRect
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 0.8
        shadow.shadowColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.15)
        deleteAccountButton.shadow = shadow

        let deleteButtonCell = deleteAccountButton.cell as? ButtonCell
        deleteButtonCell?.regularBackgroundColor = .simplenoteAlertControlBackgroundColor
        deleteButtonCell?.textColor = .simplenoteAlertControlTextColor
        deleteButtonCell?.isBordered = true
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


    private func setupThemeFields() {
        let menuItems: [NSMenuItem] = ThemeOption.allCases.map { theme in
            let item = NSMenuItem()
            item.title = theme.description
            item.tag = theme.rawValue
            return item
        }

        menuItems.forEach({ themePopUp.menu?.addItem($0) })
    }

    private func updateSelectedSortMode() {
        let sortMode = Options.shared.notesListSortMode
        sortOrderPopUp.selectItem(withTitle: sortMode.description)
    }

    private func updateSelectedTheme() {
        let theme = SPUserInterface.activeThemeOption
        themePopUp.selectItem(withTag: theme.rawValue)
    }

    private func updateLineLength() {
        if Options.shared.editorFullWidth {
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

        view.window?.close()
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
        guard let item = sender as? NSButton,
              item.identifier == NSUserInterfaceItemIdentifier.noteDisplayCondensedButton else {
            return
        }

        let isCondensedOn = item.state == .on
        Options.shared.notesListCondensed = isCondensedOn
        SPTracker.trackSettingsListCondensedEnabled(isCondensedOn)
    }

    @IBAction private func sortTagsAlphabeticallyPressed(_ sender: Any) {
        Options.shared.alphabeticallySortTags = !Options.shared.alphabeticallySortTags
    }

    // MARK: Theme Settings

    @IBAction private func themeWasPressed(_ sender: Any) {
        guard let menu = sender as? NSPopUpButton,
              let item = menu.selectedItem else {
            return
        }

        guard let option = ThemeOption(rawValue: item.tag) else {
            return
        }

        Options.shared.themeName = option.themeName
    }

    // MARK: Text Settings

    @IBAction private func textSizeHasChanged(_ sender: Any) {
        guard let sender = sender as? NSSlider else {
            return
        }

        Options.shared.fontSize = Int(sender.intValue)
        SimplenoteAppDelegate.shared().noteEditorViewController.refreshStyle()
    }


    // MARK: Analytics Settings

    @IBAction private func shareAnalyticsWasPressed(_ sender: Any) {
        guard let sender = sender as? NSButton else {
            return
        }

        let isEnabled = sender.state == .on
        Options.shared.analyticsEnabled = isEnabled
    }
}

private struct Constants {
    static let deleteNotesButton = NSLocalizedString("Delete Notes", comment: "Delete notes and sign out of the app")
    static let cancelButton = NSLocalizedString("Cancel", comment: "Cancel the action")
    static let visitWebButton = NSLocalizedString("Visit Web App", comment: "Visit app.simplenote.com in the browser")
    static let unsyncedNotesAlertTitle = NSLocalizedString("Unsynced Notes Detected", comment: "Alert title displayed in when an account has unsynced notes")
    static let unsyncedNotesMessage = NSLocalizedString("Signing out will delete any unsynced notes. Check your connection and verify your synced notes by signing in to the Web App.", comment: "Alert message displayed when an account has unsynced notes")
}
