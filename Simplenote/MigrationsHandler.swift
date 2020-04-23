import Foundation
import os.log


// MARK: - Simplenote's Upgrade handling flows
//
@objcMembers
class MigrationsHandler: NSObject {

    /// Returns the Runtime version
    ///
    private let runtimeVersion = Bundle.main.shortVersionString

    /// Stores the last known version.
    ///
    private var lastKnownVersion: String? {
        get {
            UserDefaults.standard.string(forKey: .lastKnownVersion)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .lastKnownVersion)
        }
    }

    /// Processes any routines required to (safely) handle App Version Upgrades.
    ///
    func ensureUpdateIsHandled() {
        guard runtimeVersion != lastKnownVersion else {
            return
        }

        processMigrations(to: runtimeVersion)
        lastKnownVersion = runtimeVersion
    }
}


// MARK: - Private Methods
//
private extension MigrationsHandler {

    /// Handles a migration *from* a given version, *towards* a given version
    ///
    func processMigrations(to: String) {
        processPreferencesMigrations()
    }

    /// Moves the Analytics flag from Simperium to UserDefaults.
    /// This must be done just once, right after upgrading. Our main goal is not to sync this flag anymore via Simperium, so that fresh installs are off by default.
    ///
    func processPreferencesMigrations() {
        guard UserDefaults.standard.containsObject(forKey: .analyticsEnabled) == false,
            let preferences = SimplenoteAppDelegate.shared()?.simperium?.preferencesObject()
            else {
                return
        }

        os_log("<> Migrating Preferences flag from Simperium")
        Options.shared.analyticsEnabled = preferences.analytics_enabled?.boolValue ?? false
    }
}
