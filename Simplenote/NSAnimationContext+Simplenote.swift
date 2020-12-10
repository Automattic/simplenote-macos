import Foundation
import AppKit


// MARK: - NSAnimationContext + Simplenote
//
extension NSAnimationContext {

    static func runAnimationGroup(after delay: TimeInterval,
                                  _ changes: @escaping (_ context: NSAnimationContext) -> Void,
                                  completionHandler: (() -> Void)? = nil) {
        if delay == .zero {
            runAnimationGroup(changes, completionHandler: completionHandler)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            runAnimationGroup(changes, completionHandler: completionHandler)
        }
    }
}
