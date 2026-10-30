# Handling file errors

Catch, classify, and present the errors of file operations.

## Overview

File operations of ``FinderItem/FinderItem`` throw ``FinderItem/FileError``, so a `catch` block already has the right type.

```swift
do {
    try item.copy(to: destination)
} catch {
    print(error.message)
}
```

A `FileError` pairs *what the system reported* with *where it happened*:

| | |
|---|---|
| ``FinderItem/FileError/underlyingError`` | The error from the system, as it was reported. Nothing is dropped. |
| ``FinderItem/FileError/source``, ``FinderItem/FileError/destination`` | The items of the operation. They come from the operation, never from guessing at the error. |
| ``FinderItem/FileError/intent`` | Whether the operation was reading or writing. |
| ``FinderItem/FileError/reason`` | The nature of the error, for branching. |

### Presenting an error

The ``FinderItem/FileError/message`` is the system's own text for the error. It is localized into the languages your app supports, and for most errors it names the file, so it needs no title of its own. The system leaves the file out of a few, such as text-encoding errors; ``FinderItem/FileError/source`` always has it:

```swift
AlertManager("Failed to copy", error: error).present()
```

The paths, the operation, and every nested error are in ``FinderItem/FileError/details``, drawn as a tree by DetailedDescription. They are shown in the `debugDescription`, not to users.

### Branching on the reason

Use ``FinderItem/FileError/reason`` to tell what went wrong. A reason does not depend on which operation noticed, so a missing file is ``FinderItem/FileError/Reason/noSuchFile`` whether it was `remove()`, `move(to:)`, or `contentType`:

```swift
switch error.reason {
case .noSuchFile:
    // ...
case .noPermission:
    // ...
default:
    // ...
}
```

The set of reasons is open, so a `switch` needs a `default`. Errors that match no reason are ``FinderItem/FileError/Reason/other``; they are still described in full. For more detail, use ``FinderItem/FileError/errno`` or inspect ``FinderItem/FileError/underlyingError``.

### Classifying other errors

Any error can be wrapped. This classifies errors that did not come from this package, and keeps the original as the ``FinderItem/FileError/underlyingError``:

```swift
let reason = FinderItem.FileError(error, source: item).reason
```

When your own check fails, create the error the system would have reported. The system composes the message, so it is localized too:

```swift
guard item.exists else { throw FinderItem.FileError(.noSuchFile, source: item) }
```

## Migrating from earlier versions

`FileError` no longer translates the system's error into its own codes. Code that matched `FileError.Code`, or created errors from it, changes as follows.

| Before | Now |
|---|---|
| `fileError.code == .cannotRead(reason: .noSuchFile)` | `fileError.reason == .noSuchFile` |
| `.intermediateFileNotExist` | `.noSuchFile` |
| `if case .cannotRead = fileError.code` | `switch fileError.reason { … default: … }`; use `fileError.intent` for read or write |
| `fileError.title` | The alert's own title, and `message` |
| `FileError(code: .cannotRead(reason: .noSuchFile), source: x)` | `FileError(.noSuchFile, source: x)` |
| `FileError(code: .cannotWrite(reason: .fileExists), source: x)` | `FileError(.fileExists, source: x, intent: .writing)` |
| `.cannotWrite(reason: .volumeReadOnly)` | `.readOnlyVolume` |
| `.invalidFileName` | `.invalidName` |
| `.inapplicableStringEncoding`, `.unknownStringEncoding` | `.stringEncoding` |
| `.corruptFile`, `.tooLarge`, `.unsupportedScheme`, `.noPermission`, `.outOfSpace` | the same names |
| `.cannotRead(reason: .posix(e))` | `FileError(e, source: x)`; the reason is derived from the errno |
| `.cannotUnmount(reason: .busy)` | `.busy` |
| `.unknown` | `.other`, or better, wrap the real error |
| `FileError(code: c, source: x, underlyingError: e)` | `FileError(e, source: x)` |
| `FileError.parse(e)` | `FileError(e, source: <the item you operated on>)` |
| `FileError.parse(orThrow: e)` | `let f = FileError(e, source: x); guard f.reason != .other else { throw e }` |

### What else changed

- A missing file is ``FinderItem/FileError/Reason/noSuchFile`` everywhere. Before, the same condition could be `.intermediateFileNotExist` or `.cannotRead(reason: .noSuchFile)`, depending on the operation.
- The ``FinderItem/FileError/message`` is the system's text, so it is localized. The full paths moved to ``FinderItem/FileError/details``.
- ``FinderItem/FileError/underlyingError`` is never `nil`, and ``FinderItem/FileError/source`` is a copy of the item.
- ``FinderItem/FileError`` is equal to another when they have the same reason and items. The underlying error and the intent are not compared.
- More operations throw ``FinderItem/FileError``, instead of `CocoaError` or `Errno`: reading and writing `Data`, `String` and `FileWrapper`, the `.data`, `.string` and `.fileWrapper` loaders, the extended attributes and the attribute updates, `bookmarkData(options:)`, `logsDirectory`, `contentsEqual(to:)` and `bundleItem(forResource:withExtension:subdirectory:in:)`. Code that caught `CocoaError` or `Errno` from them should use ``FinderItem/FileError/reason``, ``FinderItem/FileError/errno`` or ``FinderItem/FileError/underlyingError``.
- Operations that mix file-system errors with other kinds stay untyped, each keeping its own error: encoding and decoding with `Codable`, `DataFrame`, `NSItemProvider`, and resolving bookmark data.
- ``FinderItem/attributes`` no longer throws, as taking the snapshot never failed: it reads nothing. The attributes that can fail still throw ``FinderItem/FileError`` when they are read. `try item.attributes` still compiles, with a warning.
- `updateCurrentDirectory(to:)` reports the real reason. `contentsEqual(to:)` returns `true` for two empty files, where it used to throw. `createFile(contents:attributes:)` reports why it failed, replaces an existing file atomically as `FileManager.createFile` does, and throws when an attribute cannot be applied, which `FileManager.createFile` ignores. By then the file has been written.
