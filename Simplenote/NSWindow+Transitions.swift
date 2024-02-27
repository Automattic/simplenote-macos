import Foundation

// MARK: - NSWindow / Transitons
//
extension NSWindow {

    /// Performs a FadeIn Transition to the specified ViewController
    ///
    func transition(to viewController: NSViewController) {
        let targetView = viewController.view
        targetView.alphaValue = AppKitConstants.alpha0_0

        // Force Layout immediately: Prevent unexpected animations while fading in
        targetView.needsLayout = true
        targetView.layoutSubtreeIfNeeded()

        NSAnimationContext.runAnimationGroup { context in
            context.allowsImplicitAnimation = true
            context.duration = AppKitConstants.duration0_4
            targetView.alphaValue = AppKitConstants.alpha1_0

            self.contentViewController = viewController
            self.layoutIfNeeded()
        }
    }
}
