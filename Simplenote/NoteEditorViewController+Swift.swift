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


// MARK: - Private Helpers
//
extension NoteEditorViewController {

    /// Indicates if there's a Note onScreen
    ///
    var isDisplayingNote: Bool {
        note != nil
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

    /// Indicates if the current document can be shared
    ///
    var isShareEnabled: Bool {
        note?.content?.isEmpty == false
    }

    /// Indicates if there are multiple selected notes
    ///
    var isSelectingMultipleNotes: Bool {
        guard let selection = selectedNotes else {
            return false
        }

        return selection.count > 1
    }


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
                                    isShareEnabled: isShareEnabled,
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
    public func tokenField(_ tokenField: NSTokenField, didChange tokens: [String]) {
    }
}


// MARK: - Settings
//
private enum Settings {
    static let maximumAlphaGradientOffset = CGFloat(30)
}
