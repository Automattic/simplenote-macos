import Foundation

extension NSProgressIndicator {
    static func addProgressIndicator(to view: NSView) -> NSProgressIndicator {
        let progressIndicator = NSProgressIndicator()
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .small

        view.addSubview(progressIndicator)

        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        progressIndicator.startAnimation(view)
        return progressIndicator
    }
}
