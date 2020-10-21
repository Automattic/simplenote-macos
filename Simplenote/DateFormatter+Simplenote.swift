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

    /// Date Formatter for Interlinking References
    ///
    static let referenceFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    /// Date Formatter for History
    ///
    static let historyFormatter: DateFormatter = metricsFormatter
}
