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

    /// Stores scroll position
    ///
    func store(scrollPosition: CGFloat, for key: String) {
        var metadata = self.metadata(for: key) ?? NoteEditorMetadata()
        metadata.scrollPosition = scrollPosition
        cache[key] = metadata
    }

    /// Cleanup
    ///
    func cleanup(keeping keys: [String]) {
        cache = cache.filter({ keys.contains($0.key) })
    }
}
