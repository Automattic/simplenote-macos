import Foundation


// MARK: - SplitViewController
//
@objc
class SplitViewController: NSSplitViewController {

    /// Indicates if we're in Focus Mode (Also known as Notes List is collapsed)
    ///
    var isFocusModeEnabled: Bool {
        isNotesCollapsed
    }

    /// Indicates if the Tags List is collapsed
    ///
    var isTagsCollapsed: Bool {
        splitViewItem(ofKind: .tags).isCollapsed
    }

    /// Indicates if the Notes List is collapsed
    ///
    var isNotesCollapsed: Bool {
        splitViewItem(ofKind: .notes).isCollapsed
    }



    // MARK: - Overridden Methods

    override func loadView() {
        let splitView = SplitView()
        splitView.isVertical = true
        splitView.dividerStyle = .thin
        self.splitView = splitView
        self.view = splitView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Note: we must manually set the `autosaveName`, otherwise divider location(s) won't be properly persisted
        splitView.autosaveName = "Please Save Me!"

        /// Note: We'll enable Layer Backing, in order to fix this console message:
        /// `WARNING: The SplitView is not layer-backed, but trying to use overlay sidebars` (...)
        splitView.wantsLayer = true
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

    /// Refreshes the Collapsed State of the specified Split Item
    ///
    func refreshSplitViewItem(ofKind kind: SplitItemKind, collapsed: Bool) {
        let splitItem = splitViewItem(ofKind: kind)
        splitItem.animator().isCollapsed = collapsed
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
        let tagsSplitItem = splitViewItem(ofKind: .tags)
        let notesSplitItem = splitViewItem(ofKind: .notes)

        // State #0: Hide the Tags List
        if !isTagsCollapsed {
            tagsSplitItem.animator().isCollapsed = true

        // State #1: Hide the Notes List
        } else if !isNotesCollapsed {
            notesSplitItem.animator().isCollapsed = true

        // State #2: Show all the things
        } else {
            notesSplitItem.animator().isCollapsed = false
            tagsSplitItem.animator().isCollapsed = false
        }

        SPTracker.trackSidebarButtonPresed()
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
