import Foundation


// MARK: - Simplenote's Note Exporter Tool
//
@objc
class SPExporter: NSObject {

    /// Indicates if we should enable the Export Item after receiving a given URL Event
    ///
    @objc
    static func mustEnableExportAction(_ url: URL) -> Bool {
        return url.host == Settings.exporterUrlHostname
    }

    /// Presents the Exporter Panel from a given window. On success, this method will effectively persist all of the (LOCAL) notes
    /// at a given filesystem location.
    ///
    @objc
    func presentExporter(from window: NSWindow, simperium: Simperium) {
        let panel = NSOpenPanel()
        panel.prompt = NSLocalizedString("Export Everything", comment: "Export All Notes Action")
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.beginSheetModal(for: window) { response in
            switch response {
            case .OK:
                guard let baseURL = panel.url else {
                    break
                }

                let notes = self.notes(from: simperium)
                self.export(notes: notes, baseURL: baseURL)
            default:
                break
            }
        }
    }
}


// MARK: - Private Methods
//
private extension SPExporter {

    /// Returns all of the Notes contained within a given Simperium collection
    ///
    func notes(from simperium: Simperium) -> [Note] {
        let bucketName = Note.classNameWithoutNamespaces
        guard let allEntities = simperium.bucket(forName: bucketName)?.allObjects() else {
            return []
        }

        return allEntities.compactMap {
            $0 as? Note
        }
    }

    /// Returns the (target) filename for a given note
    ///
    func filename(for note: Note) -> String {
        let prefix = note.deleted ? Settings.trashedPrefix : Settings.regularPrefix
        return prefix + "-" + note.simperiumKey.prefix(Settings.hashMaxLenght) + Settings.pathExtension
    }

    /// Persists a collection of notes in a given location
    ///
    func export(notes: [Note], baseURL: URL) {
        for note in notes {
            let filename = self.filename(for: note)
            let targetURL = baseURL.appendingPathComponent(filename)

            try? note.content.write(to: targetURL, atomically: true, encoding: .utf8)
        }
    }
}


// MARK: - Constants
//
private enum Settings {
    static let exporterUrlHostname = "export"
    static let trashedPrefix = "TRASH"
    static let regularPrefix = "Note"
    static let pathExtension = "txt"
    static let hashMaxLenght = 7
}
