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

    /// Date Formatter for the Notes List
    ///
    static let notesFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()

    /// Date Formatter for History
    ///
    static let historyFormatter: DateFormatter = metricsFormatter
}
