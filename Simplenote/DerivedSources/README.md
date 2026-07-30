# DerivedSources

The two `SPCredentials.swift` entries here — one per consumer target, under `Simplenote/` and `IntentsExtension/` — are shown in red in Xcode and `Open Quickly` cannot find them.
That is expected: they do not exist in the repository.

The `Copy Secret` build phase writes each into its own target's `$(DERIVED_FILE_DIR)`, from the decrypted credentials under `~/.configure/simplenote-macos/secrets/`, or, missing those and outside a Release build, from the committed `SPCredentials-demo.swift`.
See `Scripts/Build-Phases/copy-secret.sh`.

Do not delete the red references. The app will not compile without them!
