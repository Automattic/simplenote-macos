import Foundation


// MARK: - SplitItemMetrics
//
enum SplitItemMetrics {

    /// Sidebar Insets
    private static let sidebarTopInsetLegacy = CGFloat(52)
    private static let sidebarTopInsetBigSur = CGFloat(62)

    /// Editor Insets
    private static let editorTopInsetLegacy = CGFloat(38)
    private static let editorTopInsetBigSur = CGFloat(48)

    
    /// Sidebar Insets: Tags + Notes Lists
    ///
    static var sidebarTopInset: CGFloat {
        guard #available(macOS 11, *) else {
            return sidebarTopInsetLegacy
        }

        return sidebarTopInsetBigSur
    }

    /// Editor Insets
    ///
    static var editorTopInset: CGFloat {
        guard #available(macOS 11, *) else {
            return editorTopInsetLegacy
        }

        return editorTopInsetBigSur
    }

    /// Header Alpha Threshold: Alpha Visibility threshold after which the Blur should be enabled
    ///
    static let headerAlphaActiveThreshold = CGFloat(0.5)

    /// Header: Maximum Offset after which alpha should be set to (1.0)
    ///
    static let headerMaximumAlphaGradientOffset = CGFloat(14)
}
