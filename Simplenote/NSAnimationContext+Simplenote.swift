import Foundation
import AppKit


// MARK: - NSAnimationContext + Simplenote
//
extension NSAnimationContext {

    static func runAnimationGroup(after delay: TimeInterval, _ changes: @escaping (_ context: NSAnimationContext) -> Void) {
        if delay == .zero {
            runAnimationGroup(changes)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            runAnimationGroup(changes)
        }
    }
}
