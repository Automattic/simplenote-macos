import Foundation


// MARK: - VersionsController
//
class VersionsController: NSObject {

    /// Ladies and gentlemen, this is yet another singleton.
    ///
    @objc
    static let shared = VersionsController()

    /// Map of event listeners.
    ///
    private let callbackMap = NSMapTable<NSString, ListenerWrapper>(keyOptions: .copyIn, valueOptions: .weakMemory)


    /// Requests the specified number of versions of Notes for a given SimperiumKey.
    ///
    /// - Parameters:
    ///     - simperiumKey: Identifier of the entity
    ///     - numberOfVersions: Number of documents to retrieve
    ///     - onResponse: Closure to be executed whenever a new version is received. This closure might be invoked `N` times.
    ///
    /// - Returns: An opaque entity, which should be retained as long as events are expected. Whenever the returned entity is released, no further events will be relayed.
    ///
    /// - Note: By design, there can be only *one* listener for changes associated to a SimperiumKey.
    ///
    func requestVersions(for simperiumKey: String, numberOfVersions: Int, onResponse: @escaping (Version) -> Void) -> Any {
        NSLog("<> Requesting \(numberOfVersions) versions for \(simperiumKey)")

        // Keep a reference to the closure
        let wrapper = ListenerWrapper(onReceive: onResponse)
        callbackMap.setObject(wrapper, forKey: simperiumKey as NSString)

        // Simperium! Yay!
        let bucket = SimplenoteAppDelegate.shared().simperium.notesBucket
        bucket.requestVersions(Int32(numberOfVersions), key: simperiumKey)

        // We'll return the wrapper as receipt
        return wrapper
    }
}


// MARK: - Simperium
//
extension VersionsController {

    @objc(didReceiveObjectForSimperiumKey:version:data:)
    func didReceiveObject(for simperiumKey: String, version: String, data: NSDictionary) {
        guard let wrapper = callbackMap.object(forKey: simperiumKey as NSString) else {
            return
        }

        guard let note = Version(version: version, payload: data) else {
            return
        }

        wrapper.block(note)
    }
}


// MARK: - BlockWrapper
//
private class ListenerWrapper: NSObject {
    let block: (Version) -> Void

    init(onReceive: @escaping (Version) -> Void) {
        block = onReceive
    }
}
