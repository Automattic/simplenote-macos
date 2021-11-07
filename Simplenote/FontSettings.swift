import Foundation

@objcMembers
class FontSettings: NSObject {
    static let minimum = CGFloat(10)
    static let normal = CGFloat(15)
    static let maximum = CGFloat(30)
    static let step = CGFloat(5)

    static func valueIsValidFontSize(_ value: CGFloat) -> Bool {
        value.truncatingRemainder(dividingBy: step) == .zero
    }

    static func nearestValidFontSize(from size: CGFloat) -> CGFloat {
        if valueIsValidFontSize(size) {
            return size
        }
        return step * (size / step).rounded()
    }
}
