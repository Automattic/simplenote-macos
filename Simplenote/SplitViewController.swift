import Foundation


// MARK: - SplitViewController
//
@objc
class SplitViewController: NSSplitViewController {

    /// Indicates if the Notes List is collapsed
    ///
    var isFocusModeEnabled: Bool {
        splitViewItem(named: .notesList).isCollapsed
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
}


// MARK: - Private Methods
//
private extension SplitViewController {

    var collapsibleItems: [NSSplitViewItem] {
        SplitViewItemName.allCases.compactMap { name in
            guard name.isCollapsible else {
                return nil
            }

            return splitViewItem(named: name)
        }
    }

    func splitViewItem(named name: SplitViewItemName) -> NSSplitViewItem {
        splitViewItems[name.index]
    }
}


// MARK: - Actions
//
extension SplitViewController {

    @IBAction
    func toggleSidebarAction(sender: Any) {
        SPTracker.trackSidebarButtonPresed()

        // Stop focus mode when the sidebar button is pressed with focus mode active
        if isFocusModeEnabled {
            focusModeAction(sender: sender)
            return
        }

        let tagsSplitItem = splitViewItem(named: .tagsList)
        tagsSplitItem.animator().isCollapsed = !tagsSplitItem.isCollapsed
    }

    @IBAction
    func focusModeAction(sender: Any) {
        let nextState = !isFocusModeEnabled

        for splitItem in collapsibleItems {
            splitItem.animator().isCollapsed = nextState
        }
    }

    @objc
    func refreshStyle() {
        guard let splitView = splitView as? SplitView else {
            fatalError()
        }

        splitView.simplenoteDividerColor = .simplenoteDividerColor
    }
}



// MARK: SplitViewItem(s) Enum
//
enum SplitViewItemName: Int, CaseIterable {
    case tagsList = 0
    case notesList = 1
    case editor = 2
}


extension SplitViewItemName {
    var index: Int {
        rawValue
    }
    var isCollapsible: Bool {
        self != .editor
    }
}
