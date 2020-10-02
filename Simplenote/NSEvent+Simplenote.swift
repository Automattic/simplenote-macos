import Foundation


// MARK: - NSEvent.SpecialKey + Simplenote
//
extension NSEvent.SpecialKey {

    /// Since the SDK does not consider `esc` as a special key, we're adding this enum case, for switch / pattern matching purposes
    ///
    static var esc: NSEvent.SpecialKey {
        NSEvent.SpecialKey(rawValue: 53)
    }
}


// MARK: - NSEvent + Simplenote
//
extension NSEvent {

    /// Same as `specialKey` but considers all of the `SpecialKey` extensible enum cases added by ourselves!
    ///
    var simplenoteSpecialKey: SpecialKey? {
        if let specialKey = specialKey {
            return specialKey
        }

        switch Int(keyCode) {
        case SpecialKey.esc.rawValue:
            return .esc
        default:
            return nil
        }
    }
}
