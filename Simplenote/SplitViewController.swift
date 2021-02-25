import Foundation


// MARK: - SplitViewController
//
@objc
class SplitViewController: NSSplitViewController {

    /// State FSM: Represents the current Display Mode
    ///
    private var state: SplitState = .everything {
        didSet {
            refreshCollapsedItems(for: state)
        }
    }

    /// State prior to toggling Focus Mode
    ///
    private var previousState: SplitState?

    /// Indicates if we're in Focus Mode (Also known as Notes List is collapsed)
    ///
    var isFocusModeEnabled: Bool {
        notesSplitItem.isCollapsed
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

    var tagsSplitItem: NSSplitViewItem {
        splitViewItem(ofKind: .tags)
    }

    var notesSplitItem: NSSplitViewItem {
        splitViewItem(ofKind: .notes)
    }

    func splitViewItem(ofKind kind: SplitItemKind) -> NSSplitViewItem {
        splitViewItems[kind.index]
    }

    func refreshCollapsedItems(for state: SplitState) {
        if tagsSplitItem.isCollapsed != state.isTagsCollapsed {
            tagsSplitItem.animator().isCollapsed = state.isTagsCollapsed
        }

        if notesSplitItem.isCollapsed != state.isNotesCollapsed {
            notesSplitItem.animator().isCollapsed = state.isNotesCollapsed
        }
    }

    func restorePreviousState() -> Bool {
        guard let nextState = previousState else {
            return false
        }

        state = nextState
        previousState = nil
        return true
    }
}


// MARK: - Actions
//
extension SplitViewController {

    @IBAction
    func toggleSidebarAction(sender: Any) {
        self.state = state.next
        self.previousState = nil

        SPTracker.trackSidebarButtonPresed()
    }

    @IBAction
    func focusModeAction(sender: Any) {
        if restorePreviousState() {
            return
        }

        let nextState: SplitState = state != .editor ? .editor : .everything
        previousState = state
        state = nextState
    }

    @objc
    func refreshStyle() {
        guard let splitView = splitView as? SplitView else {
            fatalError()
        }

        splitView.simplenoteDividerColor = .simplenoteDividerColor
    }
}


// MARK: - SplitState: Represents the Internal SplitView State
//
private enum SplitState {
    case everything
    case tagsCollapsed
    case editor
}

extension SplitState {

    var next: SplitState {
        switch self {
        case .everything:
            return .tagsCollapsed
        case .tagsCollapsed:
            return .editor
        case .editor:
            return .everything
        }
    }

    var isTagsCollapsed: Bool {
        self != .everything
    }

    var isNotesCollapsed: Bool {
        self == .editor
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

    static let listMinWidth: CGFloat = 300
    static let listMaxWidth: CGFloat = 500

    static let mainMinWidth: CGFloat = 300
    static let mainMaxWidth: CGFloat = NSSplitViewItem.unspecifiedDimension
}
