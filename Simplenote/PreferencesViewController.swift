import Cocoa

class PreferencesViewController: NSViewController {
    private var simperium: Simperium {
        SimplenoteAppDelegate.shared().simperium
    }

    @IBOutlet private var backgroundview: BackgroundView!

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
    @IBOutlet private var privacyLinkLabel: NSTextField!

    // MARK: Interactive Elements

    @IBOutlet private var logoutButton: NSButton!
    @IBOutlet private var deleteAccountButton: Button!
    @IBOutlet private var sortOrderPopUp: NSPopUpButton!
    @IBOutlet private var lineLengthFullRadio: NSButton!
    @IBOutlet private var lineLengthNarrowRadio: NSButton!
    @IBOutlet private var condensedNoteListCheckbox: NSButton!
    @IBOutlet private var sortTagsAlphabeticallyCheckbox: NSButton!
    @IBOutlet private var themePopUp: NSPopUpButton!
    @IBOutlet private var textSizeSlider: NSSlider!
    @IBOutlet private var shareAnalyticsCheckbox: NSButton!

    // Mark: Background Views
    @IBOutlet private var accountSectionBackground: BackgroundView!
    @IBOutlet private var layoutSectionBackground: BackgroundView!
    @IBOutlet private var themeSectionBackground: BackgroundView!
    @IBOutlet private var textSectionBackground: BackgroundView!


    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
        setupSortModeFields()
        setupThemeFields()
        refreshFields()
        refreshStyle()

        startListeningToNotifications()
    }

    deinit {
        stopListeningToNotifications()
    }

    @objc
    private func refreshFields() {
        updateAccountEmailLabel()

        updateSelectedSortMode()
        updateLineLength()
        updateCondensedNoteListCheckBox()
        updateSortTagsAlphabeticallyCheckbox()

        updateSelectedTheme()

        updateTextSizeSlider()

        updateShareAnalyticsCheckbox()
    }

    @objc
    private func refreshStyle() {
        backgroundview.fillColor = .simplenoteStatusBarBackgroundColor

        let allBackgrounds = [accountSectionBackground, layoutSectionBackground, themeSectionBackground,textSectionBackground]
        allBackgrounds.forEach {
            $0?.drawsBottomBorder = true
            $0?.borderColor = .simplenotePreferencesDividerColor
        }
        
        let allLabels = [emailLabel, accountTitleLabel, sortOrderLabel, lineLengthLabel, themeLabel, textSizeLabel, littleALabel, bigALabel, analyticsDescriptionLabel, privacyLinkLabel]
        allLabels.forEach { $0?.textColor = NSColor.simplenoteTextColor }

        let allButtons: [NSButton] = [logoutButton, lineLengthNarrowRadio, lineLengthFullRadio, sortOrderPopUp, condensedNoteListCheckbox, sortTagsAlphabeticallyCheckbox, themePopUp, shareAnalyticsCheckbox]
        allButtons.forEach { $0.setTitleColor(.simplenoteTextColor) }

        setupDeleteAccountButtonStyle()
    }

    private func setupDeleteAccountButtonStyle() {
        deleteAccountButton.bezelStyle = .roundRect
        deleteAccountButton.textInsets = Constants.deleteButtonInsets

        let shadow = NSShadow()
        shadow.shadowBlurRadius = AppKitConstants.alpha0_8
        shadow.shadowColor = .buttonShadowColor
        deleteAccountButton.shadow = shadow

        let cell = deleteAccountButton.cell as? ButtonCell
        cell?.regularBackgroundColor = .simplenoteAlertControlBackgroundColor
        cell?.textColor = .simplenoteAlertControlTextColor
        cell?.isBordered = true
        cell?.highlightedBackgroundColor = .simplenoteSecondarySelectedBackgroundColor
    }

    private func setupLabels() {
        accountTitleLabel.stringValue = Strings.account
        sortOrderLabel.stringValue = Strings.noteSortOrder
        lineLengthLabel.stringValue = Strings.noteLineLength
        themeLabel.stringValue = Strings.theme
        textSizeLabel.stringValue = Strings.theme

        logoutButton.title = Strings.logoutButtonLabel
        deleteAccountButton.title = Strings.deleteAccountButtonLabel
        lineLengthFullRadio.title = Strings.fullLineLengthButtonLabel
        lineLengthNarrowRadio.title = Strings.narrowLineLengthButtonLabel
        condensedNoteListCheckbox.title = Strings.condensedNoteListCheckboxLabel
        sortTagsAlphabeticallyCheckbox.title = Strings.sortTagsCheckboxLabel
        shareAnalyticsCheckbox.title = Strings.shareAnalyticsCheckboxLabel

        analyticsDescriptionLabel.stringValue = Strings.analyticsDescription
        privacyLinkLabel.attributedStringValue = Strings.privacyLink()
        privacyLinkLabel.isSelectable = true
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

    private func updateAccountEmailLabel() {
        emailLabel.stringValue = simperium.user?.email ?? ""
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

    private func updateCondensedNoteListCheckBox() {
        condensedNoteListCheckbox.state = Options.shared.notesListCondensed ? .on : .off
    }

    private func updateSortTagsAlphabeticallyCheckbox() {
        sortTagsAlphabeticallyCheckbox.state = Options.shared.alphabeticallySortTags ? .on : .off
    }

    @objc
    private func updateTextSizeSlider() {
        textSizeSlider.intValue = Int32(Options.shared.fontSize)
    }

    private func updateShareAnalyticsCheckbox() {
        shareAnalyticsCheckbox.state = Options.shared.analyticsEnabled ? .on: .off
    }

    // MARK: Account Settings

    @IBAction private func logOutWasPressed(_ sender: Any) {
        let appDelegate = SimplenoteAppDelegate.shared()

        if !StatusChecker.hasUnsentChanges(simperium) {
            appDelegate.signOut()
            self.view.window?.close()
            return
        }

        let alert = NSAlert(messageText: Strings.unsyncedNotesAlertTitle, informativeText: Strings.unsyncedNotesMessage)
        alert.addButton(withTitle: Strings.deleteNotesButton)
        alert.addButton(withTitle: Strings.cancelButton)
        alert.addButton(withTitle: Strings.visitWebButton)
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

    // MARK: Note List Appearence Settings

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

        Options.shared.fontSize = CGFloat(sender.floatValue)
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

private struct Strings {
    static let account = NSLocalizedString("Account:", comment: "Account label")
    static let noteSortOrder = NSLocalizedString("Note sort order:", comment: "Note Sort Order label")
    static let noteLineLength = NSLocalizedString("Note line length:", comment: "Note line length label")
    static let theme = NSLocalizedString("Theme:", comment: "Theme label")
    static let textSize = NSLocalizedString("Text size:", comment: "Text size control label")
    static let logoutButtonLabel = NSLocalizedString("Logout", comment: "Logout button label")
    static let deleteAccountButtonLabel = NSLocalizedString("Delete Account", comment: "Delete account button label")
    static let fullLineLengthButtonLabel = NSLocalizedString("Full", comment: "Full line length button label")
    static let narrowLineLengthButtonLabel = NSLocalizedString("Narrow", comment: "Narrow line length button label")
    static let condensedNoteListCheckboxLabel = NSLocalizedString("Condensed Note List", comment: "Condensed note list button label")
    static let sortTagsCheckboxLabel = NSLocalizedString("Sort Tags Alphabetically", comment: "Sort tags alphabetically checkbox label")
    static let shareAnalyticsCheckboxLabel = NSLocalizedString("Share Analytics", comment: "Share analytics checkbox label")
    static let deleteNotesButton = NSLocalizedString("Delete Notes", comment: "Delete notes and sign out of the app")
    static let cancelButton = NSLocalizedString("Cancel", comment: "Cancel the action")
    static let visitWebButton = NSLocalizedString("Visit Web App", comment: "Visit app.simplenote.com in the browser")
    static let unsyncedNotesAlertTitle = NSLocalizedString("Unsynced Notes Detected", comment: "Alert title displayed in when an account has unsynced notes")
    static let unsyncedNotesMessage = NSLocalizedString("Signing out will delete any unsynced notes. Check your connection and verify your synced notes by signing in to the Web App.", comment: "Alert message displayed when an account has unsynced notes")

    static let analyticsDescription = NSLocalizedString("Help us to improve Simplenote by automatically sending analytics data from this device. This includes data about general usage in the app and does not include any personal information.", comment: "A description about how we use anayltics")
    static let linkText = NSLocalizedString("About Analytics and Privacy", comment: "A link to more information about our privacy policy")
    static func privacyLink() -> NSMutableAttributedString {
        let link = NSMutableAttributedString(string: linkText)
        link.addAttribute(.link, value: "https://automattic.com/privacy/", range: link.fullRange)

        return link
    }
}

// MARK: - Notifications
//
private extension PreferencesViewController {

    func startListeningToNotifications() {
        guard #available(macOS 10.15, *) else {
            return
        }

        NotificationCenter.default.addObserver(self, selector: #selector(refreshStyle), name: .ThemeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextSizeSlider), name: .FontSizeDidChange, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

private struct Constants {
    static let deleteButtonInsets = NSEdgeInsets(top: .zero, left: 4, bottom: 1, right: 4)
}
