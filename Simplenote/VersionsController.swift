import Foundation


// MARK: - VersionsController
//
class VersionsController: NSObject {

    /// Ladies and gentlemen, this is yet another singleton.
    ///
    @objc
    static let shared = VersionsController()

    /// NoteVersions cache: SimperiumKey > Version > NoteVersion
    ///
    private var versions = [String: [String: NoteVersion]]()

    /// Requests the specified number of versions to the backend
    ///
    func requestVersions(simperiumKey: String, numberOfVersions: Int) {
        NSLog("<> Requesting \(numberOfVersions) versions for \(simperiumKey)")

        // Nuke our cache
        versions[simperiumKey] = [:]

        // Simperium! Yay!
        let bucket = SimplenoteAppDelegate.shared().simperium.notesBucket
        bucket.requestVersions(Int32(numberOfVersions), key: simperiumKey)
    }

    /// Stops accepting new version documents
    ///
    func dropAllRequests() {
        versions = [:]
    }

    /// Returns the NoteVersion for a given SimperiumKey / Version pair
    ///
    func version(forSimperiumKey simperiumKey: String, version: Int) -> NoteVersion? {
        versions[simperiumKey]?[String(version)]
    }
}


// MARK: - Simperium
//
extension VersionsController {

    @objc(didReceiveObjectForSimperiumKey:version:data:)
    func didReceiveObject(for simperiumKey: String, version: String, data: NSDictionary) {
        versions[simperiumKey]?[version] = NoteVersion(payload: data)
    }
}
