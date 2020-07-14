import Foundation


// MARK: - Interface Initialization
//
extension NoteEditorViewController {

    @objc
    func setupStatusImageView() {
        statusImageView.image = NSImage(named: .simplenoteLogoInner)
        statusImageView.tintImage(color: .simplenotePlaceholderTintColor)
    }

    @objc
    func setupScrollView() {
        scrollView.contentView.postsBoundsChangedNotifications = true
    }

    @objc
    func setupTopDivider() {
        topDividerView.alphaValue = .zero
        topDividerView.drawsBottomBorder = true
    }

    @objc
    func setupTagsField() {
        tagsField.delegate = self
        tagsField.focusRingType = .none
        tagsField.font = .simplenoteSecondaryTextFont
        tagsField.placeholderText = NSLocalizedString("Add tag...", comment: "Placeholder text in the Tags View")
        tagsField.nextKeyView = noteEditor
    }
}


// MARK: - Autolayout FTW
//
extension NoteEditorViewController {

    open override func updateViewConstraints() {
        if mustUpdateToolbarConstraint {
            updateToolbarTopConstraint()
        }

        super.updateViewConstraints()
    }

    var mustUpdateToolbarConstraint: Bool {
        // Why check `.isActive`?:
        // Because we're in a midway refactor. The NoteList.view is, initially, embedded elsewhere.
        // TODO: Simplify this check, the second MainMenu.xib is cleaned up!
        toolbarViewTopConstraint == nil || toolbarViewTopConstraint?.isActive == false
    }

    func updateToolbarTopConstraint() {
        guard let layoutGuide = toolbarView.window?.contentLayoutGuide as? NSLayoutGuide else {
            return
        }

        toolbarViewTopConstraint = toolbarView.topAnchor.constraint(equalTo: layoutGuide.topAnchor)
        toolbarViewTopConstraint.isActive = true
    }
}


// MARK: - Internal State
//
extension NoteEditorViewController {

    /// Indicates if there's a Note onScreen
    ///
    var isDisplayingNote: Bool {
        note != nil
    }

    /// Indicates if the current document is not empty
    ///
    var isDisplayingContent: Bool {
        note?.content?.isEmpty == false
    }

    /// Indicates if the Markdown Preview UI is active
    ///
    @objc
    var isDisplayingMarkdown: Bool {
        markdownViewController.parent != nil
    }

    /// Indicates if the current document is expected to support Markdown
    ///
    var isMarkdownEnabled: Bool {
        note?.markdown == true
    }

    /// Indicates if there are multiple selected notes
    ///
    var isSelectingMultipleNotes: Bool {
        let numberOfSelectedNotes = selectedNotes?.count ?? .zero
        return numberOfSelectedNotes > 1
    }
}


// MARK: - Refreshing Interface
//
extension NoteEditorViewController {

    /// Refreshes the Editor's Inner State
    ///
    @objc
    func refreshEditorActions() {
        noteEditor.isEditable = isDisplayingNote && !viewingTrash
        noteEditor.isSelectable = isDisplayingNote && !viewingTrash
        noteEditor.isHidden = isDisplayingMarkdown
    }

    /// Refreshes the Toolbar's Inner State
    ///
    @objc
    func refreshToolbarActions() {
        let newState = ToolbarState(isDisplayingNote: isDisplayingNote,
                                    isDisplayingMarkdown: isDisplayingMarkdown,
                                    isMarkdownEnabled: isMarkdownEnabled,
                                    isSelectingMultipleNotes: isSelectingMultipleNotes,
                                    isViewingTrash: viewingTrash)
        toolbarView.state = newState
    }

    /// Refreshes all of the TagsField properties: Tokens and allowed actions
    ///
    @objc
    func refreshTagsField() {
        refreshTagsFieldActions()
        refreshTagsFieldTokens()
    }

    /// Refreshes the TagsField's Inner State
    ///
    @objc
    func refreshTagsFieldActions() {
        let isEnabled = isDisplayingNote && !viewingTrash
        tagsField.drawsPlaceholder = isEnabled
        tagsField.isEditable = isEnabled
        tagsField.isSelectable = isEnabled
    }

    /// Refreshes the TagsField's Tokens
    ///
    private func refreshTagsFieldTokens() {
        tagsField.tokens = note?.tagsArray as? [String] ?? []
    }
}


// MARK: - NSMenuItemValidation
//
extension NoteEditorViewController: NSMenuItemValidation {

    public func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let identifier = menuItem.identifier else {
            return true
        }

        switch identifier {
        case .editorPinMenuItem:
            return validatePinMenuItem(menuItem)

        case .editorMarkdownMenuItem:
            return validateMarkdownMenuItem(menuItem)

        case .editorShareMenuItem:
            return validateShareMenuItem(menuItem)

        case .editorHistoryMenuItem:
            return validateHistoryMenuItem(menuItem)

        case .editorTrashMenuItem:
            return validateTrashMenuItem(menuItem)

        case .editorPublishMenuItem:
            return validatePublishMenuItem(menuItem)

        case .editorCollaborateMenuItem:
            return validateCollaborateMenuItem(menuItem)

        case .systemNewNoteMenuItem:
            return validateNewNoteMenuItem(menuItem)

        case .systemPrintMenuItem, .systemTrashMenuItem:
            return validatePrintMenuItem(menuItem)

        default:
            return true
        }
    }

    func validatePinMenuItem(_ item: NSMenuItem) -> Bool {
        let isPinnedOn = selectedNotes.allSatisfy { $0.pinned }
        item.state = isPinnedOn ? .on : .off
        return true
    }

    func validateMarkdownMenuItem(_ item: NSMenuItem) -> Bool {
        let isMarkdownOn = selectedNotes.allSatisfy { $0.markdown }
        item.state = isMarkdownOn ? .on : .off
        return true
    }

    func validateShareMenuItem(_ item: NSMenuItem) -> Bool {
        isDisplayingContent
    }

    func validateHistoryMenuItem(_ item: NSMenuItem) -> Bool {
        isDisplayingNote && !isDisplayingMarkdown
    }

    func validateTrashMenuItem(_ item: NSMenuItem) -> Bool {
        isDisplayingNote || isSelectingMultipleNotes
    }

    func validatePublishMenuItem(_ item: NSMenuItem) -> Bool {
        isDisplayingContent
    }

    func validateCollaborateMenuItem(_ item: NSMenuItem) -> Bool {
        isDisplayingNote
    }

    func validateNewNoteMenuItem(_ item: NSMenuItem) -> Bool {
        !viewingTrash
    }

    func validatePrintMenuItem(_ item: NSMenuItem) -> Bool {
        !viewingTrash && note != nil && SimplenoteAppDelegate.shared().isMainWindowVisible()
    }
}


// MARK: - Actions
//
extension NoteEditorViewController {

    @IBAction
    func metricsWasPressed(sender: Any) {
        guard !dismissMetricsPopoverIfNeeded(), let notes = selectedNotes else {
            return
        }

        displayMetricsPopover(from: toolbarView.metricsButton, for: notes)
    }

    @IBAction
    func collaborateWasPressed(sender: Any) {
        SPTracker.trackEditorCollaboratorsAccessed()
        displayCollaboratePopover(from: tagsField)
        tagsField.becomeFirstResponder()
    }

    @IBAction
    func publishWasPressed(sender: Any) {
        guard let note = note else {
            return
        }

        displayPublishPopover(from: toolbarView.moreButton, for: note)
    }

    @IBAction
    func shareWasPressed(sender: Any) {
        guard let content = note?.content else {
            return
        }

        displaySharingPicker(from: toolbarView.moreButton, content: content)
    }

    @IBAction
    func versionsWasPressed(sender: Any) {
        guard let note = note else {
            return
        }

        SPTracker.trackEditorVersionsAccessed()
        displayVersionsPopover(from: toolbarView.moreButton, for: note)
    }
}


// MARK: - Popovers / Pickers
//
extension NoteEditorViewController {

    func displayMetricsPopover(from sourceView: NSView, for notes: [Note]) {
        let viewController = MetricsViewController(notes: notes)
        present(viewController, asPopoverRelativeTo: sourceView.bounds, of: sourceView, preferredEdge: .maxY, behavior: .transient)
    }

    func displayPublishPopover(from sourceView: NSView, for note: Note) {
        let viewController = PublishViewController(note: note)
        viewController.delegate = self
        present(viewController, asPopoverRelativeTo: sourceView.bounds, of: sourceView, preferredEdge: .maxY, behavior: .transient)
    }

    func displayCollaboratePopover(from sourceView: NSView) {
        let viewController = CollaborateViewController()
        present(viewController, asPopoverRelativeTo: sourceView.bounds, of: sourceView, preferredEdge: .maxY, behavior: .transient)
    }

    func displaySharingPicker(from sourceView: NSView, content: String) {
        let picker = NSSharingServicePicker(items: [content])
        picker.show(relativeTo: sourceView.bounds, of: sourceView, preferredEdge: .minY)
    }

    func displayVersionsPopover(from sourceView: NSView, for note: Note) {
        let viewController = VersionsViewController(note: note)
        viewController.delegate = self
        present(viewController, asPopoverRelativeTo: sourceView.bounds, of: sourceView, preferredEdge: .maxY, behavior: .transient)
    }

    func dismissMetricsPopoverIfNeeded() -> Bool {
        guard let metricsViewController = metricsViewController else {
            return false
        }

        dismiss(metricsViewController)
        return true
    }
    var metricsViewController: NSViewController? {
        presentedViewControllers?.first { $0 is MetricsViewController }
    }
}


// MARK: - Markdown Rendering
//
extension NoteEditorViewController {

    @objc(displayMarkdownPreview:)
    func displayMarkdownPreview(_ markdown: String) {
        markdownViewController.markdown = markdown
        attachMarkdownViewController()
        refreshTopDividerAlpha()
    }

    @objc
    func dismissMarkdownPreview() {
        markdownViewController.markdown = nil
        detachMarkdownViewController()
        refreshTopDividerAlpha()
    }

    private func attachMarkdownViewController() {
        let markdownView = markdownViewController.view
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(markdownView)

        NSLayoutConstraint.activate([
            markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            markdownView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            markdownView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])

        addChild(markdownViewController)
    }

    private func detachMarkdownViewController() {
        markdownViewController.view.removeFromSuperview()
        markdownViewController.removeFromParent()
    }
}


// MARK: - Notifications
//
extension NoteEditorViewController {

    @objc
    func startListeningToScrollNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clipViewDidScroll),
                                               name: NSView.boundsDidChangeNotification,
                                               object: scrollView.contentView)
    }

    @objc
    func clipViewDidScroll(sender: Notification) {
        refreshTopDividerAlpha()
    }

    private func refreshTopDividerAlpha() {
        topDividerView.alphaValue = alphaForTopDivider
    }

    private var alphaForTopDivider: CGFloat {
        guard markdownViewController.parent == nil else {
            return AppKitConstants.alpha1_0
        }

        let contentOffSetY = scrollView.documentVisibleRect.origin.y
        return min(max(contentOffSetY / Settings.maximumAlphaGradientOffset, 0), 1)
    }
}


// MARK: - TagsFieldDelegate
//
extension NoteEditorViewController: TagsFieldDelegate {

    public func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        // Disable Autocomplete:
        // We cannot control the direction of the suggestions layer. Fullscreen causes such element to be offscreen.
        guard tokenField.window?.styleMask.contains(.fullScreen) == false else {
            return []
        }

        // Search Tags starting with the new keyword
        let suggestions = SimplenoteAppDelegate.shared().simperium.searchTagNames(prefix: substring)

        // Return **Only** the Sorted Subset that's not already in the note.
        return note.filterUnassociatedTagNames(from: suggestions).sorted()
    }

    public func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
        guard let note = note, let tags = tokens as? [String] else {
            return []
        }

        return note.filterUnassociatedTagNames(from: tags).caseInsensitiveUnique
    }

    public func tokenField(_ tokenField: NSTokenField, didChange tokens: [String]) {
        // NSTokenField is expected to call `shouldAdd` before this API runs. However... that doesn't always happen.
        // Whenever there's a new Tag onscreen (not yet `committed`), and the user clicks elsewhere,
        // the `shouldAdd` API won't get hit.
        //
        // For that reason, we'll filtering out duplicates.
        //
        updateTags(withTokens: tokens.caseInsensitiveUnique)
    }
}


// MARK: - PublishViewControllerDelegate
//
extension NoteEditorViewController: PublishViewControllerDelegate {

    func publishControllerDidClickPublish(_ controller: PublishViewController) {
        SPTracker.trackEditorNotePublished()
        note.published = true
        save()
    }

    func publishControllerDidClickUnpublish(_ controller: PublishViewController) {
        SPTracker.trackEditorNoteUnpublished()
        note.published = false
        save()
    }
}


// MARK: - VersionsViewControllerDelegate
//
extension NoteEditorViewController: VersionsViewControllerDelegate {

    func versionsController(_ controller: VersionsViewController, selected version: Version) {
        noteEditor.displayNote(content: version.content)
    }

    func versionsControllerDidClickRestore(_ controller: VersionsViewController) {
        note.content = noteEditor.plainTextContent()
        save()

        SPTracker.trackEditorNoteRestored()
        dismiss(controller)
    }

    func versionsControllerWillShow(_ controller: VersionsViewController) {
        noteEditor.isEditable = false
    }

    func versionsControllerWillClose(_ controller: VersionsViewController) {
        // Unload versions and re-enable editor
        noteEditor.isEditable = true

        // Refreshes the note content in the editor, in case the popover was canceled
        didReceiveNewContent()
    }
}


// MARK: - Settings
//
private enum Settings {
    static let maximumAlphaGradientOffset = CGFloat(30)
}
