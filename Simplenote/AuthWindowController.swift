import Foundation
import AppKit


// MARK: - AuthWindowController
//
class AuthWindowController: NSWindowController, SPAuthenticationInterface {

    /// Starting Point!
    ///
    let authViewController = AuthViewController()

    /// Simperium's Authenticator Instance
    ///
    var authenticator: SPAuthenticator? {
        didSet {
            authViewController.authenticator = authenticator
        }
    }


    // MARK: - Initializer

    init() {
        let window = NSWindow(contentViewController: authViewController)
        window.styleMask = [.borderless, .closable, .titled, .fullSizeContentView]
        window.appearance = NSAppearance(named: .aqua)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
