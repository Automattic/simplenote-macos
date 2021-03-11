import Foundation


// MARK: - InterlinkProcessorDelegate
//
protocol InterlinkProcessorDelegate: NSObjectProtocol {

    /// Invoked whenever an Autocomplete Row has been selected: The handler should insert the specified text at a given range
    ///
    func interlinkProcessor(_ processor: InterlinkProcessor, insert text: String, in range: Range<String.Index>)
}


// MARK: - InterlinkProcessor
//
class InterlinkProcessor: NSObject {

    /// Hosting TextView
    ///
    private let parentTextView: SPTextView

    /// Storage Lookup
    ///
    private let resultsController: InterlinkResultsController

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

    /// Insertion Delegate
    ///
    weak var delegate: InterlinkProcessorDelegate?


    /// Designated Initialier
    ///
    init(viewContext: NSManagedObjectContext, parentTextView: SPTextView) {
        self.resultsController = InterlinkResultsController(viewContext: viewContext)
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
            dismissInterlinkLookup()
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

        dismissInterlinkLookup()
    }

    /// DIsmisses the Interlink Window
    ///
    func dismissInterlinkLookup() {
        interlinkWindowController.close()
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

    /// Refreshes the Interlink UI
    ///
    func refreshInterlinkController(notes: [Note]) {
        interlinkViewController.notes = notes
    }

    /// Sets up the Replacement Callback Mechanism
    ///
    func setupInterlinkEventListeners(replacementRange: Range<String.Index>) {
        interlinkViewController.onInsertInterlink = { [weak self] text in
            guard let `self` = self else {
                return
            }

            self.delegate?.interlinkProcessor(self, insert: text, in: replacementRange)
        }
    }
}
