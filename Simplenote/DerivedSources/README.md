# DerivedSources

Xcode shows two `SPCredentials.swift` entries in the project navigator under
`DerivedSources/Simplenote/` and `DerivedSources/IntentsExtension/`.
Both appear in **red** with an empty **Full Path** in the File Inspector.
This is **expected** and **harmless**.

## Why they are red and "not accessible"

Both file references use `sourceTree = DERIVED_FILE_DIR`.
`DERIVED_FILE_DIR` is a *per-target, per-configuration* build setting that only has a value while a specific target is actively being built.
The project navigator is populated at project-parse time, before any build and with no target or configuration context, so Xcode has no single absolute path to resolve.
The File Inspector still shows **Location: Relative to DERIVED_FILE_DIR**, confirming the declaration is understood — there just isn't one path to display, because it differs between the `Simplenote` and `IntentsExtension` targets, and per configuration.

At **build time** Xcode resolves `DERIVED_FILE_DIR` per target, a `Copy Secret` script build phase on each consumer target writes `SPCredentials.swift` into that target's own derived sources directory under Derived Data, and the Swift compiler reads it back from that same location.
The actual paths look like:

```
~/Library/Developer/Xcode/DerivedData/Simplenote-<hash>/
  Build/Intermediates.noindex/Simplenote.build/<config>/
    Simplenote.build/DerivedSources/SPCredentials.swift        # Simplenote target
    IntentsExtension.build/DerivedSources/SPCredentials.swift  # IntentsExtension target
```

Search a build log for `Applying Production Secrets` or `Applying Example Secrets` to see the exact path for the current build.

## How to actually view a generated file

1. Build the target at least once.
2. Right-click the red `SPCredentials.swift` entry in the navigator and pick **Show in Finder** — Xcode opens the per-target derived sources folder for the most recent build of that target.

## The generation pipeline itself

Lives in `Scripts/Build-Phases/copy-secret.sh` and its `copy-secret.xcfilelist`.
The script copies the decrypted credentials from outside the checkout, falling back to `Simplenote/SPCredentials-demo.swift` for non-Release builds so the app compiles without secrets.
