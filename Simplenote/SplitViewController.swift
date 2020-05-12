import Foundation


// MARK: - SplitViewController
//
@objc
class SplitViewController: NSSplitViewController {

    ///
    ///
    var isNotesListCollapsed: Bool {
        splitViewItems[1].isCollapsed
    }


    // MARK: - Overridden Methods

    override func loadView() {
        let splitView = SplitView()
        splitView.isVertical = true
        self.splitView = splitView
        self.view = splitView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        splitView.autosaveName = "Please Save Me!"
    }


    // MARK: - Actions

    @IBAction
    func toggleSidebarAction(sender: Any) {
        SPTracker.trackSidebarButtonPresed()

        // Stop focus mode when the sidebar button is pressed with focus mode active
        guard !isNotesListCollapsed else {
            focusModeAction(sender: sender)
            return
        }

        let tagsSplitItem = splitViewItems[0]
        tagsSplitItem.animator().isCollapsed = !tagsSplitItem.isCollapsed
    }

    @IBAction
    func focusModeAction(sender: Any) {
        let nextState = !isNotesListCollapsed

        for splitItem in [splitViewItems[0], splitViewItems[1]] {
            splitItem.animator().isCollapsed = nextState
        }
    }

    @objc
    func refreshStyle() {
        guard let splitView = splitView as? SplitView else {
            return
        }

        splitView.simplenoteDividerColor = .simplenoteDividerColor
    }
}


class SplitView: NSSplitView {

    var simplenoteDividerColor: NSColor? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }

    override var dividerThickness: CGFloat {
        NSScreen.main?.pointToPixelRatio ?? 1
    }

    override func drawDivider(in rect: NSRect) {
        guard let dividerColor = simplenoteDividerColor else {
            return
        }

        dividerColor.setFill()
        NSBezierPath(rect: rect).fill()
    }
}
