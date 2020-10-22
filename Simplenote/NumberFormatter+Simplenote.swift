import Foundation


// MARK: - NumberFormatter
//
extension NumberFormatter {

    class func localizedString(from integer: Int, style: NumberFormatter.Style) -> String {
        let wrappedInt = NSNumber(integerLiteral: integer)
        return NumberFormatter.localizedString(from: wrappedInt, number: style)
    }
}
