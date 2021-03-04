import AppKit

// MARK: - NoteEditorMetadataCache
//
@objc
class NoteEditorMetadataCache: NSObject {
    typealias ScrollCache = [String: NoteEditorMetadata]

    private var cache: ScrollCache {
        didSet {
            try? storage.save(object: cache)
        }
    }

    private var noteContentBeforeUpdate: [String: String] = [:]

    private let storage: FileStorage<ScrollCache>

    init(storage: FileStorage<ScrollCache>) {
        self.storage = storage

        let storedCache = try? storage.load()
        cache = storedCache ?? [:]
    }

    /// Returns cached metadata
    ///
    func metadata(for key: String) -> NoteEditorMetadata? {
        return cache[key]
    }

    /// Stores metadata
    ///
    func store(metadata: NoteEditorMetadata, for key: String) {
        cache[key] = metadata
    }

    /// Remove metadata for key
    ///
    func cleanup(keeping keys: [String]) {
        cache = cache.filter({ keys.contains($0.key) })
    }

    /// Remove all cached data
    ///
    @objc
    func removeAll() {
        cache.removeAll()
    }
}

// MARK: - Updating cursor
//
extension NoteEditorMetadataCache {
    @objc(willUpdateNote:)
    func willUpdate(note: Note) {
        guard let key = note.simperiumKey else {
            return
        }

        noteContentBeforeUpdate[key] = note.content ?? ""
    }

    @objc(didUpdateNote:)
    func didUpdate(note: Note) {
        guard let key = note.simperiumKey else {
            return
        }

        guard let oldContent = noteContentBeforeUpdate.removeValue(forKey: key) else {
            return
        }

        guard let oldMetadata = metadata(for: key), let oldCursorLocation = oldMetadata.cursorLocation else {
            return
        }

        let location = (oldContent as NSString).convertCursorLocation(oldCursorLocation, toLocationInText: note.content ?? "")
        let metadata = NoteEditorMetadata(scrollPosition: oldMetadata.scrollPosition,
                                          cursorLocation: location)
        store(metadata: metadata, for: key)
    }
}
