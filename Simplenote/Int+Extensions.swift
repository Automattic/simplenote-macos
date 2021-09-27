import Foundation

extension Int {
    func roundToNearestFive() -> Int {
        return 5 * Int((Double(self) / 5.0).rounded())
    }
}
