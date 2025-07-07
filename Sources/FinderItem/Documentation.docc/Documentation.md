# ``FinderItem``

The FinderItem Package.

## Overview

The ``FinderItem/FinderItem`` provides a great abstraction over the ways in which you can interact with the file system.

It abstracts over many structures, including `FileManager`, `URL`, `FilePath`, and more.

### Highlights
- Load contents using ``FinderItem/FinderItem/load(_:)-7spks``.
- Inspect if file ``FinderItem/FinderItem/exists`` or ``FinderItem/FinderItem/isDirectory``.
- Inspect file ``FinderItem/FinderItem/stem`` & ``FinderItem/FinderItem/extension``.
- Gets ``FinderItem/FinderItem/contentType``.
- File operations including ``FinderItem/FinderItem/copy(to:)``,  ``FinderItem/FinderItem/move(to:)-3wp1t``, ``FinderItem/FinderItem/remove()``.
- ``FinderItem/FinderItem/open(configuration:)`` or ``FinderItem/FinderItem/reveal()`` files
- Get sorted children as a stream using ``FinderItem/FinderItem/children(range:)``.
- [Typed throws](``FinderItem/FinderItem/FileError``).
- Get and insert attributes: ``FinderItem/load(_:)``, ``FinderItem/insertAttribute(_:_:)``.


## Getting Started

`FinderItem` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://www.github.com/Vaida12345/FinderItem", from: "1.0.0")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://www.github.com/Vaida12345/FinderItem
```
