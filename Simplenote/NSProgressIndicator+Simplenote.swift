import Foundation

extension NSProgressIndicator {
    static func addProgressIndicator(to view: NSView) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator.init(frame: NSRect(x: view.frame.minX, y: view.frame.midY, width: 20, height: 20))
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.style = .spinning

        view.addSubview(progressIndicator)

        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        progressIndicator.startAnimation(view)
        return progressIndicator
    }
}
