import Foundation


// MARK: - ProcessInfo
//
extension ProcessInfo {

    /// Indicates if we're running Unit Tests, or we're happily in a regular environment =)
    ///
    @objc
    static func isRunningTests() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
