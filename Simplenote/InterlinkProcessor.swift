import Foundation


// MARK: - InterlinkProcessor
//
class InterlinkProcessor: NSObject {

    /// Interlink Popover
    ///
    private lazy var interlinkWindowController: PopoverWindowController = {
        let popoverWindowController = PopoverWindowController()
        popoverWindowController.contentViewController = interlinkViewController
        return popoverWindowController
    }()

    /// Interlink ViewController!
    ///
    private lazy var interlinkViewController = InterlinkViewController()

    /// Hosting TextView
    ///
    private let parentTextView: SPTextView


    /// Designated Initialier
    ///
    init(parentTextView: SPTextView) {
        self.parentTextView = parentTextView
    }


    /// Displays the Interlink Lookup Window at the cursor's location when all of the following are **true**:
    ///
    ///     1. We're not performing an Undo OP
    ///     2. There is no Highlighted Text in the editor
    ///     3. There is an interlink `[keyword` at the current location
    ///     4. There are Notes with `keyword` in their title
    ///
    ///  Otherwise we'll simply dismiss the Autocomplete Window, if any.
    ///
    @objc(processInterlinkLookupExcludingEntityID:)
    func processInterlinkLookup(excludedEntityID: NSManagedObjectID) {
        guard mustProcessInterlinkLookup,
              let (markdownRange, keywordRange, keywordText) = parentTextView.interlinkKeywordAtSelectedLocation,
              refreshInterlinks(for: keywordText, in: markdownRange, excluding: excludedEntityID)
        else {
            dismissInterlinkWindow()
            return
        }

        displayInterlinkWindow(around: keywordRange)
    }

    /// Dismisses the Interlink Window when ANY of the following evaluates **true**:
    ///
    ///     1.  There is Highlighted Text in the editor (or)
    ///     2.  There is no Interlink `[keyword` at the selected location
    ///
    @objc
    func dismissInterlinkLookupIfNeeded() {
        guard mustDismissInterlinkLookup else {
            return
        }

        dismissInterlinkWindow()
    }
}


// MARK: - Interlinking Autocomplete: Private API(s)
//
private extension InterlinkProcessor {

    /// Indicates if the Selected Range's Length is non zero: at least one character is highlighted
    ///
    var isSelectingText: Bool {
        parentTextView.selectedRange().length != .zero
    }

    /// Indicates if there's an ongoing Undo Operation in the Text Editor
    ///
    var isUndoingEditOP: Bool {
        parentTextView.undoManager?.isUndoing == true
    }

    /// Indicates if the Interlink Window is visible
    ///
    var isInterlinkWindowOnScreen: Bool {
        interlinkWindowController.window?.parent != nil
    }
}


// MARK: - Interlinking Autocomplete: Private API(s)
//
private extension InterlinkProcessor {

    /// Indicates if we should process Interlink Lookup
    ///
    var mustProcessInterlinkLookup: Bool {
        isUndoingEditOP == false && isSelectingText == false
    }

    /// Indicates if we should dismiss the Interlink Window
    ///
    var mustDismissInterlinkLookup: Bool {
        isSelectingText || isInterlinkWindowOnScreen && parentTextView.interlinkKeywordAtSelectedLocation == nil
    }

    /// Presents the Interlink PopoverWindow at a given Editor Range (Below / Above!)
    ///
    func displayInterlinkWindow(around range: Range<String.Index>) {
        let locationOnScreen = parentTextView.locationOnScreenForText(in: range)
        let parentWindow = parentTextView.window!

        interlinkWindowController.attach(to: parentWindow)
        interlinkWindowController.positionWindow(relativeTo: locationOnScreen)
    }

    /// DIsmisses the Interlink Window
    ///
    func dismissInterlinkWindow() {
        interlinkWindowController.close()
    }

    /// Refreshes the Interlinks for a given Keyword at the specified Replacement Range (including Markdown `[` opening character).
    /// - Returns: `true` whenever there *are* interlinks to be presented
    ///
    func refreshInterlinks(for keywordText: String, in replacementRange: Range<String.Index>, excluding excludedID: NSManagedObjectID?) -> Bool {
        interlinkViewController.onInsertInterlink = { [weak self] text in
            self?.parentTextView.insertTextAndLinkify(text: text, in: replacementRange)
            self?.dismissInterlinkWindow()
        }

        return interlinkViewController.refreshInterlinks(for: keywordText, excluding: excludedID)
    }
}
