import Foundation


// MARK: - DateFormatter
//
extension DateFormatter {

    /// Date Formatter for Note Metrics
    ///
    static let metricsFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

