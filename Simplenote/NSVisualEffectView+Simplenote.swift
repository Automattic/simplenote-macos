import Foundation
import AppKit

// MARK: - NSVisualEffectView.Material
//
extension NSVisualEffectView.Material {

    /// Returns the Material to be applied over the Tags List
    ///
    static var simplenoteTaglistMaterial: NSVisualEffectView.Material {
        return .underWindowBackground
    }
}

// MARK: - NSVisualEffectView
//
extension NSVisualEffectView {

    /// ObjC Convenience API: Wraps access to `NSVisualEffect.Material.simplenoteTaglistMaterial`, which otherwise would not be accessible
    ///
    @objc
    static var simplenoteTaglistMaterial: NSVisualEffectView.Material {
        .simplenoteTaglistMaterial
    }
}
