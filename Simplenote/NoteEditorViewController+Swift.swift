import Foundation
import SimplenoteFoundation
import SimplenoteInterlinks
import SimplenoteSearch


// MARK: - EditorControllerDelegate
//
@objc
protocol EditorControllerDelegate: AnyObject {
    func editorController(_ controller: NoteEditorViewController, updatedNoteContents: Note)
}


// MARK: - Interface Initialization
//
extension NoteEditorViewController {

    @objc
    func setupStatusImageView() {
        statusImageView.image = NSImage(named: .simplenoteLogoInner)
        statusImageView.contentTintColor = .simplenotePlaceholderTintColor
    }

    @objc
    func setupScrollView() {
        scrollView.contentView.postsBoundsChangedNotifications = true
    }

    @objc
    func setupTagsField() {
        tagsField.delegate = self
        tagsField.focusRingType = .none
        tagsField.font = .simplenoteSecondaryTextFont
        tagsField.placeholderText = NSLocalizedString("Add tag...", comment: "Placeholder text in the Tags View")
        tagsField.nextKeyView = noteEditor
        tagsField.formatter = TagTextFormatter(maximumLength: SimplenoteConstants.maximumTagLength)
    }

    @objc
    func setupInterlinksProcessor() {
        interlinkProcessor = InterlinkProcessor(viewContext: simplenoteAppDelegate.managedObjectContext,
                                                parentTextView: noteEditor)
        interlinkProcessor.delegate = self
    }

    @objc
    func setupBottomInsets() {
        tagsViewBottomConstraint.constant = SplitItemMetrics.breadcrumbsViewHeight
    }

    @objc
    func refreshScrollInsets() {
        clipView.contentInsets.top = SplitItemMetrics.editorContentTopInset
        scrollView.scrollerInsets.top = SplitItemMetrics.editorScrollerTopInset
    }
}


// MARK: - Public
//
extension NoteEditorViewController {

    /// Makes editor first responder
    ///
    func focus() {
        view.window?.makeFirstResponder(noteEditor)
    }

    func tagsControllerDidUpdateFilter(_ newFilter: TagListFilter) {
        viewingTrash = newFilter == .deleted
        refreshEditorActions()
        refreshToolbarActions()
        refreshTagsFieldActions()
    }
}


// MARK: - Layout
//
extension NoteEditorViewController {

    open override func updateViewConstraints() {
        if mustSetupSemaphoreLeadingConstraint {
            setupSemaphoreLeadingConstraint()
        }

        refreshSemaphoreLeadingConstant()
        super.updateViewConstraints()
    }

    /// Indicates if the Semaphore Leading hasn't been initialized
    ///
    private var mustSetupSemaphoreLeadingConstraint: Bool {
        sidebarSemaphoreLeadingConstraint == nil
    }

    /// # Semaphore Leading:
    /// We REALLY need to avoid collisions between the Sidebar Button and the Window's Semaphore (Zoom / Close buttons).
    ///
    /// - Important:
    ///     `priority` is set to `defaultLow` (250) for the constraint between Button and Window.contentLayoutGuide, whereas the regular `leading` is set to (249).
    ///     This way we avoid choppy NSSplitView animations (using a higher priority interfers with AppKit internals!)
    ///
    private func setupSemaphoreLeadingConstraint() {
        guard let contentLayoutGuide = view.window?.contentLayoutGuide as? NSLayoutGuide else {
            return
        }

        let sidebarLeadingAnchor = toolbarView.sidebarButton.leadingAnchor
        let newConstraint = sidebarLeadingAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.leadingAnchor)
        newConstraint.priority = .defaultLow
        newConstraint.isActive = true
        sidebarSemaphoreLeadingConstraint = newConstraint
    }

    /// Refreshes the Semaphore Leading
    ///
    private func refreshSemaphoreLeadingConstant() {
        guard let semaphorePaddingX = view.window?.semaphorePaddingX else {
            return
        }

        sidebarSemaphoreLeadingConstraint?.constant = semaphorePaddingX + SplitItemMetrics.toolbarSemaphorePaddingX
    }
}


// MARK: - Display Mode
//
extension NoteEditorViewController {

    @objc
    func refreshTextContainer() {
        guard let container = noteEditor.textContainer else {
            fatalError()
        }

        let superviewWidth = view.frame.width
        let targetMaxTextWidth = maximumTextWidth(for: superviewWidth)
        let targetContainerInset = textContainerInset(superviewWidth: superviewWidth, maximumTextWidth: targetMaxTextWidth)
        let targetContainerSize = textContainerSize(superviewWidth: superviewWidth, textContainerInset: targetContainerInset)

        noteEditor.textContainerInset = targetContainerInset
        container.containerSize = targetContainerSize

        /// Note: Disabling `widthTracksTextView` fixes jumpy Scroll Offsets on resize
        /// Ref. https://github.com/Automattic/simplenote-macos/issues/536
        container.widthTracksTextView = false
    }

    private func maximumTextWidth(for superviewWidth: CGFloat) -> CGFloat {
        Options.shared.editorFullWidth ? superviewWidth : min(EditorMetrics.maximumNarrowWidth, superviewWidth)
    }

    /// Whenever `SuperviewWidth > MaximumTextWidth` this API will return an Inset which will center onscreen the TextContainer
    ///
    private func textContainerInset(superviewWidth: CGFloat, maximumTextWidth: CGFloat) -> NSSize {
        let width = max((superviewWidth - maximumTextWidth), .zero) * 0.5
        return NSMakeSize(width + EditorMetrics.minimumPadding, EditorMetrics.minimumPadding)
    }

    /// # Note: Why not receiving the MaximumTextWidth instead?
    /// Because in Narrow Display we intend to center the TextContainer, and such calculation is actually done in `textContainerInset`
    ///
    private func textContainerSize(superviewWidth: CGFloat, textContainerInset: NSSize) -> NSSize {
        let width = superviewWidth - textContainerInset.width * 2
        return NSSize(width: width, height: .greatestFiniteMagnitude)
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
    @objc
    var isMarkdownEnabled: Bool {
        note?.markdown == true
    }

    /// Indicates if there are multiple selected notes
    ///
    var isSelectingMultipleNotes: Bool {
        selectedNotes.count > 1
    }

    /// Simperium 🖖
    ///
    var simperium: Simperium {
        simplenoteAppDelegate.simperium
    }

    /// TODO: Let's decouple with dependency injection (OR) a delegate please!!
    ///
    var simplenoteAppDelegate: SimplenoteAppDelegate {
        SimplenoteAppDelegate.shared()
    }
}


// MARK: - Refreshing Interface
//
extension NoteEditorViewController {

    /// Refreshes the Editor's Interface
    ///
    @objc
    func refreshInterface() {
        refreshToolbarActions()
        refreshEditorActions()
        refreshEditorText()
        refreshTagsField()
    }

    /// Refreshes the Editor's Inner State
    ///
    @objc
    func refreshEditorActions() {
        noteEditor.isEditable = isDisplayingNote && !viewingTrash
        noteEditor.isSelectable = isDisplayingNote && !viewingTrash
        noteEditor.isHidden = isDisplayingMarkdown
    }

    /// Refreshes the Editor's Text
    ///
    @objc
    func refreshEditorText() {
        displayContent(note?.content)
    }

    /// Refreshes the Editor's UX
    ///
    @objc
    func refreshStyle() {
        backgroundView.fillColor                = .simplenoteSecondaryBackgroundColor
        headerDividerView.borderColor           = .simplenoteDividerColor
        bottomDividerView.borderColor           = .simplenoteSecondaryDividerColor
        noteEditor.insertionPointColor          = .simplenoteEditorTextColor
        noteEditor.textColor                    = .simplenoteEditorTextColor
        statusTextField.textColor               = .simplenoteSecondaryTextColor
        tagsField.textColor                     = .simplenoteTextColor
        tagsField.placeholderTextColor          = .simplenoteSecondaryTextColor

        if let note = note {
            storage.refreshStyle(markdownEnabled: note.markdown)
        }
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

    @objc
    func resetTagsFieldScrollOffset() {
        tagsField.scroll(.zero)
    }

    /// Refreshes the TagsField's Tokens
    ///
    private func refreshTagsFieldTokens() {
        tagsField.tokens = note?.tagsArray as? [String] ?? []
    }
}


// MARK: - NotesControllerSearchDelegate
//
extension NoteEditorViewController: NotesControllerSearchDelegate {

    func notesControllerDidSearch(_ query: SearchQuery?) {
        searchQuery = query
        updateKeywordsHighlight()
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
        case .editorCopyInterlinkMenuItem:
            return validateEditorCopyInterlinkMenuItem(menuItem)

        case .editorPinMenuItem:
            return validateEditorPinMenuItem(menuItem)

        case .editorMarkdownMenuItem:
            return validateEditorMarkdownMenuItem(menuItem)

        case .editorShareMenuItem:
            return validateEditorShareMenuItem(menuItem)

        case .editorHistoryMenuItem:
            return validateEditorHistoryMenuItem(menuItem)

        case .editorTrashMenuItem:
            return validateSystemTrashMenuItem(menuItem)

        case .editorPublishMenuItem:
            return validateEditorPublishMenuItem(menuItem)

        case .editorCollaborateMenuItem:
            return validateEditorCollaborateMenuItem(menuItem)

        case .systemNewNoteMenuItem:
            return validateSystemNewNoteMenuItem(menuItem)

        case .systemPrintMenuItem:
            return validateSystemPrintMenuItem(menuItem)

        case .systemTrashMenuItem:
            return validateSystemTrashMenuItem(menuItem)

        default:
            return true
        }
    }

    func validateEditorCopyInterlinkMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Copy Internal Link", comment: "Copy Link Menu Action")
        return isDisplayingNote
    }

    func validateEditorPinMenuItem(_ item: NSMenuItem) -> Bool {
        let isPinnedOn = selectedNotes.allSatisfy { $0.pinned }
        item.state = isPinnedOn ? .on : .off
        item.title = NSLocalizedString("Pin to Top", comment: "Pin to Top Menu Action")
        return true
    }

    func validateEditorMarkdownMenuItem(_ item: NSMenuItem) -> Bool {
        let isMarkdownOn = selectedNotes.allSatisfy { $0.markdown }
        item.state = isMarkdownOn ? .on : .off
        item.title = NSLocalizedString("Markdown", comment: "Markdown Menu Action")
        return true
    }

    func validateEditorShareMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Share", comment: "Share Menu Action")
        return isDisplayingContent
    }

    func validateEditorHistoryMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("History", comment: "History Menu Action")
        return isDisplayingNote && !isDisplayingMarkdown
    }

    func validateEditorTrashMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Move to Trash", comment: "Trash Menu Action")
        return isDisplayingNote || isSelectingMultipleNotes
    }

    func validateEditorPublishMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Publish", comment: "Publish Menu Action")
        return isDisplayingContent
    }

    func validateEditorCollaborateMenuItem(_ item: NSMenuItem) -> Bool {
        item.title = NSLocalizedString("Collaborate", comment: "Collaborate Menu Action")
        return isDisplayingNote
    }

    func validateSystemNewNoteMenuItem(_ item: NSMenuItem) -> Bool {
        return !viewingTrash
    }

    func validateSystemPrintMenuItem(_ item: NSMenuItem) -> Bool {
        return !viewingTrash && note != nil && view.window?.isVisible == true
    }

    func validateSystemTrashMenuItem(_ item: NSMenuItem) -> Bool {
        guard viewingTrash == false, view.window?.isVisible == true else {
            return false
        }

        return isDisplayingNote || isSelectingMultipleNotes
    }

    func validateToogleMarkdownPreviewItem(_ item: NSMenuItem) -> Bool {
        return isMarkdownEnabled
    }
}


// MARK: - Actions
//
extension NoteEditorViewController {

    @IBAction
    func sidebarWasPressed(sender: Any) {
        SimplenoteAppDelegate.shared().cycleSidebarAction()
    }

    @IBAction
    func metricsWasPressed(sender: Any) {
        guard !dismissMetricsPopoverIfNeeded() else {
            return
        }

        displayMetricsPopover(from: toolbarView.metricsButton, for: selectedNotes)
    }

    @IBAction
    func collaborateWasPressed(sender: Any) {
        SPTracker.trackEditorCollaboratorsAccessed()
        displayCollaboratePopover(from: tagsField)
        tagsField.becomeFirstResponder()
    }

    @IBAction
    func copyInterlinkWasPressed(sender: Any) {
        guard let note = note else {
            return
        }

        SPTracker.trackEditorCopiedInternalLink()
        NSPasteboard.general.copyInterlink(to: note)
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
        viewController.delegate = self
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
    func displayMarkdownPreview(_ note: Note) {
        markdownViewController.startDisplayingContents(of: note)
        attachMarkdownViewController()
        refreshHeaderState()
    }

    @objc
    func dismissMarkdownPreview() {
        detachMarkdownViewController()
        refreshHeaderState()
    }

    private func attachMarkdownViewController() {
        let markdownView = markdownViewController.view
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(markdownView)

        NSLayoutConstraint.activate([
            markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            markdownView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor),
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
    func startListeningToWindowNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(windowDidResize),
                                               name: NSWindow.didResizeNotification,
                                               object: nil)
    }

    @objc
    func clipViewDidScroll(sender: Notification) {
        refreshHeaderState()
    }

    @objc
    func windowDidResize(sender: Notification) {
        // We might need to adjust the constraints (in order to prevent collisions with the Window Semaphore)
        view.needsUpdateConstraints = true
    }

    @objc
    func refreshHeaderState() {
        let newAlpha = alphaForHeader
        headerDividerView.alphaValue = newAlpha
        headerEffectView.alphaValue = newAlpha
        headerEffectView.state = newAlpha > SplitItemMetrics.headerAlphaActiveThreshold ? .active : .inactive
    }

    private var alphaForHeader: CGFloat {
        guard markdownViewController.parent == nil else {
            return AppKitConstants.alpha1_0
        }

        let contentOffSetY = scrollView.documentVisibleRect.origin.y + clipView.contentInsets.top
        return min(max(contentOffSetY / SplitItemMetrics.headerMaximumAlphaGradientOffset, 0), 1)
    }
}


// MARK: - TagsFieldDelegate
//
extension NoteEditorViewController: TagsFieldDelegate {

    public func tokenField(_ tokenField: NSTokenField, completionsForSubstring substring: String, indexOfToken tokenIndex: Int, indexOfSelectedItem selectedIndex: UnsafeMutablePointer<Int>?) -> [Any]? {
        guard let note = note else {
            return []
        }

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
        guard let note = note else {
            return
        }

        updateNoteTags(tokens: tokens.caseInsensitiveUnique, note: note)
    }
}


// MARK: - Tags Processing
//
extension NoteEditorViewController {

    /// TODO: Let's analyze and potentially build NotesController / TagsController
    ///
    func updateNoteTags(tokens: [String], note: Note) {
        let newTags = tokens.filter { token in
            simperium.searchTag(name: token) == nil && token.containsEmailAddress() == false
        }

        for newTag in newTags {
            tagActionsDelegate?.editorController(self, didAddNewTag: newTag)
        }

        // Update Tags: Internally they're JSON Encoded!
        let oldTags = note.tags
        note.setTagsFromList(tokens)

        guard note.tags != oldTags else {
            return
        }

        save()
        ensureSelectedNoteIsVisible(oldTags: oldTags, newTags: note.tags, simperiumKey: note.simperiumKey)
    }

    /// Displays the current Note in the Notes List whenever we're filtering by Tag, and such String gets removed from the Tags collection
    ///
    private func ensureSelectedNoteIsVisible(oldTags: String?, newTags: String?, simperiumKey: String) {
        guard case let .tag(selectedTag) = simplenoteAppDelegate.selectedTagFilter,
              oldTags?.contains(selectedTag) == true,
              newTags?.contains(selectedTag) == false
        else {
            return
        }

        simplenoteAppDelegate.displayNote(simperiumKey: simperiumKey)
    }
}


// MARK: - PublishViewControllerDelegate
//
extension NoteEditorViewController: PublishViewControllerDelegate {

    func publishControllerDidClickPublish(_ controller: PublishViewController) {
        guard let note = note else {
            return
        }

        SPTracker.trackEditorNotePublished()
        note.published = true
        save()
    }

    func publishControllerDidClickUnpublish(_ controller: PublishViewController) {
        guard let note = note else {
            return
        }

        SPTracker.trackEditorNoteUnpublished()
        note.published = false
        save()
    }
}


// MARK: - VersionsViewControllerDelegate
//
extension NoteEditorViewController: VersionsViewControllerDelegate {

    func versionsController(_ controller: VersionsViewController, selected version: Version) {
        displayContent(version.content)
    }

    func versionsControllerDidClickRestore(_ controller: VersionsViewController) {
        guard let note = note else {
            return
        }

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


// MARK: - MetricsControllerDelegate
//
extension NoteEditorViewController: MetricsControllerDelegate {

    /// When displaying a reference, we need to:
    ///     A.  Switch to the `All Notes` Tag Row, if the target note isn't visible.
    ///     B.  Select the target note
    ///     C.  Refresh the Editor
    ///
    /// - Note: Since the AppDelegate holds references to all the things, the simplest approach is to just relay back the message.
    /// - Important: We may need change this in the future, if support for detachable editors becomes a requirement.
    ///
    func metricsController(_ controller: MetricsViewController, selected note: Note) {
        SimplenoteAppDelegate.shared().displayNote(simperiumKey: note.simperiumKey)
        dismiss(controller)
    }
}


// MARK: - Content and Highlights
//
extension NoteEditorViewController {

    @objc
    func displayContent(_ content: String?) {
        noteEditor.displayNote(content: content ?? "")
        DispatchQueue.main.async { [weak self] in
            self?.updateKeywordsHighlight()
        }
    }

    @objc
    func observeEditorIsFirstResponder() {
        noteEditor.onUpdateFirstResponder = { [weak self] in
            self?.updateKeywordsHighlight()
        }
    }

    private var highlightedRanges: [NSRange] {
        guard !noteEditor.isFirstResponder, let searchQuery = searchQuery as? SearchQuery, !searchQuery.keywords.isEmpty else {
            return []
        }

        let slice = noteEditor.attributedString().string.contentSlice(matching: searchQuery.keywords)
        return slice?.nsMatches ?? []
    }

    private func updateKeywordsHighlight() {
        let ranges = highlightedRanges

        noteEditor.highlightedRanges = ranges

        createSearchMapViewIfNeeded()
        searchMapView?.update(with: noteEditor.relativeLocationsForText(in: ranges))
    }
}


// MARK: - Search Map
//
extension NoteEditorViewController {
    private func createSearchMapViewIfNeeded() {
        guard searchMapView == nil else {
            return
        }

        let searchMapView = SearchMapView()
        searchMapView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(searchMapView)

        NSLayoutConstraint.activate([
            searchMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchMapView.widthAnchor.constraint(equalToConstant: EditorMetrics.searchMapWidth),
            searchMapView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            searchMapView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: SplitItemMetrics.editorScrollerTopInset)
        ])

        self.searchMapView = searchMapView
    }
}


// MARK: - Shortcuts
//
extension NoteEditorViewController {
    @objc
    func toggleTagsAndEditor() {
        if noteEditor.isFirstResponder {
            view.window?.makeFirstResponder(tagsField)
            tagsField.currentEditor()?.moveToEndOfDocument(nil)
            tagsField.ensureCaretIsOnscreen()
        } else {
            view.window?.makeFirstResponder(noteEditor)
        }
    }
}


// MARK: - Editor Metadata
//
extension NoteEditorViewController {
    @objc
    func saveScrollPositionAndCursorLocation() {
        // Issue #393: `self.note` might be populated, but it's simperiumKey inaccessible
        guard let simperiumKey = note?.simperiumKey else {
            return
        }

        let scrollPosition = scrollView.contentView.bounds.origin.y
        let cursorLocation = noteEditor.selectedRange().location
        let metadata = NoteEditorMetadata(scrollPosition: scrollPosition,
                                          cursorLocation: cursorLocation)
        metadataCache.store(metadata: metadata, for: simperiumKey)
    }

    @objc
    func restoreScrollPosition() {
        guard let simperiumKey = note?.simperiumKey,
              let scrollPosition = metadataCache.metadata(for: simperiumKey)?.scrollPosition else {
            scrollView.scrollToTop(animated: false)
            return
        }
        // ensure layout to make sure that content size is updated
        noteEditor.ensureLayout()
        scrollView.documentView?.scroll(NSPoint(x: 0, y: scrollPosition))
    }

    @objc
    func restoreCursorLocation() {
        guard let simperiumKey = note?.simperiumKey,
              let cursorLocation = metadataCache.metadata(for: simperiumKey)?.cursorLocation else {
            return
        }
        noteEditor.setSelectedRange(NSRange(location: cursorLocation, length: 0))
    }
}


// MARK: - Interlinks Insertion
//
extension NoteEditorViewController: InterlinkProcessorDelegate {

    func interlinkProcessor(_ processor: InterlinkProcessor, insert text: String, in range: Range<String.Index>) {
        noteEditor.insertTextAndLinkify(text: text, in: range)
        processor.dismissInterlinkLookup()
    }
}


// MARK: - EditorMetrics
//
private enum EditorMetrics {

    /// Note: This matches the Electron apps max editor width
    ///
    static let maximumNarrowWidth = CGFloat(750)

    /// Minimum Text Padding: To be applied Vertically / Horizontally
    ///
    static let minimumPadding = CGFloat(20)

    /// Search map width
    ///
    static let searchMapWidth = CGFloat(12)
}
