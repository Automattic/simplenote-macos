import Foundation


// MARK: - SplitViewController
//
@objc
class SplitViewController: NSSplitViewController {

    /// Indicates if the Notes List is collapsed
    ///
    var isFocusModeEnabled: Bool {
        splitViewItem(ofKind: .notes).isCollapsed
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


// MARK: - Public API
//
extension SplitViewController {

    /// Inserts a SplitViewItem of the specified kind:
    /// -   Position will be automatically set for you
    /// -   Maximum and Minimum thickness is derived from the Item Kind
    ///
    func insertSplitViewItem(_ splitViewItem: NSSplitViewItem, kind: SplitItemKind) {
        splitViewItem.collapseBehavior = .useConstraints
        splitViewItem.minimumThickness = kind.minimumThickness
        splitViewItem.maximumThickness = kind.maximumThickness
        insertSplitViewItem(splitViewItem, at: kind.index)
    }
}


// MARK: - Private API(s)
//
private extension SplitViewController {

    var collapsibleItems: [NSSplitViewItem] {
        SplitItemKind.allCases.compactMap { kind in
            guard kind.isCollapsible else {
                return nil
            }

            return splitViewItem(ofKind: kind)
        }
    }

    func splitViewItem(ofKind kind: SplitItemKind) -> NSSplitViewItem {
        splitViewItems[kind.index]
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

        let tagsSplitItem = splitViewItem(ofKind: .tags)
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



// MARK: SplitItemName(s) Enum
//
enum SplitItemKind: Int, CaseIterable {
    case tags = 0
    case notes = 1
    case editor = 2
}


// MARK: - SplitItemName Properties
//
extension SplitItemKind {

    var index: Int {
        rawValue
    }

    var isCollapsible: Bool {
        self != .editor
    }

    var minimumThickness: CGFloat {
        switch self {
        case .tags:
            return Metrics.tagsMinWidth
        case .notes:
            return Metrics.listMinWidth
        case .editor:
            return Metrics.mainMinWidth
        }
    }

    var maximumThickness: CGFloat {
        switch self {
        case .tags:
            return Metrics.tagsMaxWidth
        case .notes:
            return Metrics.listMaxWidth
        case .editor:
            return Metrics.mainMaxWidth
        }
    }
}


// MARK: - SplitView's Metrics
//
private enum Metrics {
    static let tagsMinWidth: CGFloat = 150
    static let tagsMaxWidth: CGFloat = 300

    static let listMinWidth: CGFloat = 200
    static let listMaxWidth: CGFloat = 500

    static let mainMinWidth: CGFloat = 300
    static let mainMaxWidth: CGFloat = NSSplitViewItem.unspecifiedDimension
}
