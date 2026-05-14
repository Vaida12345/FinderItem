# Secure Scope

Work with security-scoped resources and bookmarks.

## Overview

When a user-selected file needs to be retained for future use, direct access is typically revoked.
To regain access later, persist a bookmark and resolve it when needed.

`FinderItem` facilitates this process through `CodableWithConfiguration`.
Instead of standard `Codable` calls, encode and decode with a bookmark configuration.
                                                    
```swift
// To encode:
try container.encode(item, configuration: [.withSecurityScope])

// To decode:
try container.decode(FinderItem.self, configuration: [.withSecurityScope])
```

You still need to call ``FinderItem/startAccessingSecurityScopedResource()`` before accessing the file, or use ``FinderItem/withAccessingSecurityScopedResource(perform:)``.

For user-selected files and folders, request access through a system picker, persist bookmark data, and resolve it when needed.


### Bookmarks

- Note: You only need these methods when handling bookmarks manually; otherwise encoding and decoding with `withSecurityScope` is sufficient.

To preserve access, use ``FinderItem/bookmarkData(options:)``. The returned bookmark data can later be resolved into a security-scoped URL.

To create a `FinderItem` from persisted data, use ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``.
On return, `bookmarkDataIsStale` indicates whether the stored bookmark should be refreshed.


## Topics
### Explicitly Handle Security Scope

- ``FinderItem/startAccessingSecurityScopedResource()``
- ``FinderItem/stopAccessingSecurityScopedResource()``
- ``FinderItem/withAccessingSecurityScopedResource(perform:)``

### Explicitly Handle Bookmark

- ``FinderItem/bookmarkData(options:)``
- ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``
- ``FinderItem/defaultBookmarkCreationOptions``
- ``FinderItem/defaultBookmarkResolveOptions``
