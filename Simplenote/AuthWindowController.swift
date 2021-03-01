import Foundation
import AppKit


// MARK: - AuthWindowController
//
class AuthWindowController: NSWindowController, SPAuthenticationInterface {

    /// Simperium's Authenticator Instance
    ///
    var authenticator: SPAuthenticator?


    // MARK: - Initializer

    init() {
        let styleMask: NSWindow.StyleMask = [.borderless, .closable, .titled, .fullSizeContentView]
        let window = NSWindow(contentRect: .zero, styleMask: styleMask, backing: .buffered, defer: false, screen: nil)
        window.appearance = NSAppearance(named: .aqua)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        super.init(window: window)

        self.contentViewController = AuthViewController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
