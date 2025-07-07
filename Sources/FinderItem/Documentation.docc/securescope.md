# Secure Scope

Work with Secure Scopes

## Overview

When a user-selected file needs to be retained for future use, the permission to read it is typically revoked. To work around this issue, a bookmark is necessary. 

`FinderItem` facilitates this process through the `CodableWithConfiguration` system. Instead of employing the standard encoding approach used with `Codable`, one should utilize `configuration`.
                                                    
```swift
// To encode:
try container.encode(item, configuration: [.withSecurityScope])

// To decode:
try container.decode(FinderItem.self, configuration: [.withSecurityScope])
```

You would still need to call ``FinderItem/startAccessingSecurityScopedResource()`` prior to accessing the file.

- Experiment: It seems you can only call ``FinderItem/startAccessingSecurityScopedResource()`` on the *original* file, not the ones derived using, for example, ``FinderItem/appending(path:directoryHint:)``. This means, to access a child folder, you need to access the security scope of its parent.

Certain folders are write-only, for example, even with `com.apple.security.files.downloads.read-write`, there is no way to access the contents of Downloads folder using ``FinderItem/downloadsDirectory``, you need to use a dialog to ask for permission. Then, you can access the contents by persisting its bookmark data.

However, with `com.apple.security.files.downloads.read-write`, it seems you do not need to start security scope to access its contents. However, you would still need the bookmark data obtained from the dialog.


### Bookmarks

- Note: You only need to uses these methods when you choose to handle bookmarks manually, otherwise encode and decode with `withSecurityScope` configuration is sufficient.

To preserve the access to the security scope, you need to use ``FinderItem/bookmarkData(options:)``. This function returns the bookmark data that can be used to create the url with the security scope.

To create `FinderItem` from the bookmark, use ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``. On return, `bookmarkDataIsStale` serves as an indicator of whether the persisted bookmark data needs to be updated.


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
