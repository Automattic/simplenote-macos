import Foundation


// MARK: - InterlinkProcessor
//
class InterlinkProcessor: NSObject {

    /// Main MOC
    ///
    private let viewContext: NSManagedObjectContext

    /// Hosting TextView
    ///
    private let parentTextView: SPTextView
    
    /// Storage Lookup
    ///
    private lazy var resultsController = InterlinkResultsController(viewContext: viewContext)

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


    /// Designated Initialier
    ///
    init(viewContext: NSManagedObjectContext, parentTextView: SPTextView) {
        self.viewContext = viewContext
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
              let notes = resultsController.searchNotes(byTitleKeyword: keywordText, excluding: excludedEntityID)
        else {
            dismissInterlinkWindow()
            return
        }

        refreshInterlinkController(notes: notes)
        setupInterlinkEventListeners(replacementRange: markdownRange)

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


    /// Refreshes the Interlink UI
    ///
    func refreshInterlinkController(notes: [Note]) {
        interlinkViewController.notes = notes
    }

    /// Sets up the Replacement Callback Mechanism
    ///
    func setupInterlinkEventListeners(replacementRange: Range<String.Index>) {
        interlinkViewController.onInsertInterlink = { [weak self] text in
            self?.parentTextView.insertTextAndLinkify(text: text, in: replacementRange)
            self?.dismissInterlinkWindow()
        }
    }
}
