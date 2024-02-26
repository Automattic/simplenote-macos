import Foundation
import AppKit

// MARK: - NSFont + Simplenote
//
extension NSFont {

    var lineHeight: CGFloat {
        ceil(ascender - descender)
    }
}
