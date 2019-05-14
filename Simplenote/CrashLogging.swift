import Foundation
import AutomatticTracks

@objc(CrashLogging)
class CrashLoggingShim: NSObject {
    @objc static func start(withSimperium simperium: Simperium) {
        let dataProvider = SPCrashLoggingDataProvider(withSimperium: simperium)
        CrashLogging.start(withDataProvider: dataProvider)
    }

    @objc static var userHasOptedOut: Bool {
        get {
            return CrashLogging.userHasOptedOut
        }
        set {
            CrashLogging.userHasOptedOut = newValue
        }
    }
}

class SPCrashLoggingDataProvider: CrashLoggingDataProvider {

    let simperium: Simperium

    init(withSimperium simperium: Simperium) {
        self.simperium = simperium
    }

    var sentryDSN: String {
        guard
            let configURL = Bundle.main.url(forResource: "config", withExtension: "plist"),
            let dictionary = NSDictionary(contentsOf: configURL)
        else {
            fatalError("Unable to read config.plist. The app cannot continue running.")
        }

        return dictionary.object(forKey: "SimplenoteSentryDSN") as! String
    }

    var userHasOptedOut: Bool {
        guard let analyticsEnabled = simperium.preferencesObject()?.analytics_enabled?.boolValue else {
            return true
        }

        return !analyticsEnabled
    }

    var buildType: String {

        #if APP_STORE_BUILD
        return  "app-store"
        #endif

        #if PUBLIC_BUILD
        return "public"
        #endif

        return "developer-internal"
    }

    var currentUser: TracksUser? {
        guard let user = self.simperium.user, let email = user.email else {
            return nil
        }

        return TracksUser(userID: email, email: email, username: email)
    }
}
