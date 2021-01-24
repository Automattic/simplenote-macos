import Foundation


// MARK: - SplitItemMetrics
//
enum SplitItemMetrics {

    /// Sidebar Insets
    private static let sidebarTopInsetLegacy = CGFloat(52)
    private static let sidebarTopInsetBigSur = CGFloat(62)

    /// Editor: Content Insets
    private static let editorContentTopInsetLegacy = CGFloat(38)
    private static let editorContentTopInsetBigSur = CGFloat(48)

    
    /// Sidebar Insets: Tags + Notes Lists
    ///
    static var sidebarTopInset: CGFloat {
        guard #available(macOS 11, *) else {
            return sidebarTopInsetLegacy
        }

        return sidebarTopInsetBigSur
    }

    /// List Insets: Content / Top
    ///
    static var listContentTopInset: CGFloat {
        sidebarTopInset
    }

    /// List Insets: Content / Bottom
    ///
    static var listContentBottomInset: CGFloat {
        let bottomInsetBigSur: CGFloat = 10
        guard #available(macOS 11, *) else {
            return .zero
        }

        return bottomInsetBigSur
    }

    /// List Insets: Scroller
    ///
    static var listScrollerTopInset: CGFloat {
        sidebarTopInset
    }

    /// Editor Insets: Content
    ///
    static var editorContentTopInset: CGFloat {
        guard #available(macOS 11, *) else {
            return editorContentTopInsetLegacy
        }

        return editorContentTopInsetBigSur
    }

    /// Editor Insets: Scroller
    ///
    static var editorScrollerTopInset: CGFloat {
        sidebarTopInset
    }

    /// Header Alpha Threshold: Alpha Visibility threshold after which the Blur should be enabled
    ///
    static let headerAlphaActiveThreshold = CGFloat(0.5)

    /// Header: Maximum Offset after which alpha should be set to (1.0)
    ///
    static let headerMaximumAlphaGradientOffset = CGFloat(14)

    /// Spacing required between the Window's Semaphore (Close / Minimize / Maximize) and the first View component
    ///
    static let toolbarSemaphorePaddingX = CGFloat(16)
}
