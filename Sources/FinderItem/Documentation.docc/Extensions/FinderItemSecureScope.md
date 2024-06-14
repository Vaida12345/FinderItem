# Working with Security Scope

To work with App Sandbox, you need to work with Security Scope.

## Overview

When one need to persist an user selected file for later usage, the permission for reading is discarded. To prevent this, a bookmark is required. ``FinderItem`` provides this functionality using `CodableWithConfiguration`. Instead of encoding the way one would encode some `Codable`, use `configuration` instead.

```swift
// To encode:
try container.encode(item, configuration: [.withSecurityScope])

// To decode:
try container.decode(FinderItem.self, configuration: [.withSecurityScope])
```

You would still need to call ``FinderItem/tryAccessSecurityScope()`` before and after accessing the file.

- Experiment: It seems you can only call ``FinderItem/tryAccessSecurityScope()`` on the *original* file, not the ones derived using, for example, ``FinderItem/appending(path:directoryHint:)``. This would mean that to access a child folder, you need to access the security scope of its parent.

Certain folders are write-only, for example, even with `com.apple.security.files.downloads.read-write`, there is no way to access the contents of Downloads folder created by ``FinderItem/downloadsDirectory``, you need to use a dialog to ask for permission. Then, you can access the contents by persisting its bookmark data.

However, with `com.apple.security.files.downloads.read-write`, it seems you do not need to start security scope to access its contents. However, you would still need the bookmark data obtained from the dialog.


### Bookmarks

To preserve the access to the security scope, you need to use ``FinderItem/bookmarkData(options:)``. This function returns the bookmark data that can be used to create the url with the security scope.

To create `FinderItem` from the bookmark, use ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``. On return, `bookmarkDataIsStale` serves as an indicator of whether the persisted bookmark data needs to be updated.


### Ask user for permissions

With `com.apple.security.files.user-selected.read-write`, you could ask users for files using `fileImporter`, or `NSPenal`. FinderItem also offers integrated streamline of asking for permission and storing the bookmark. To read more, see ``FinderItem/tryPromptAccessFile()``. 


## Topics

### Explicitly Handle Security Scope

- ``FinderItem/tryAccessSecurityScope()``
- ``FinderItem/stopAccessSecurityScope()``
- ``withAccessingSecurityScopedResource(to:perform:)``


### Explicitly Handle Bookmark

- ``FinderItem/bookmarkData(options:)``
- ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``


### Integrated Streamline
- ``FinderItem/tryPromptAccessFile()``
