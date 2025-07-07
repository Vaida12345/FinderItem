# The FinderItem

The FinderItem Package.

## Overview

The ``FinderItem/FinderItem`` provides a great abstraction over the ways in which you can interact with the file system.

It abstracts over many structures, including `FileManager`, `URL`, `FilePath`, and more.

### Highlights
- Load contents using [``load(_:)``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/load(_:)-97hgq/).
- Inspect if file [``exists``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/exists) or [``isDirectory``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/isdirectory).
- Inspect file [``stem``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/stem) & [``extension``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/extension).
- Gets [``contentType``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/contenttype).
- File operations including [``copy(to:)``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/copy(to:)),  [``move(to:)``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/move(to:)-5oihl), [``remove()``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/remove()).
- [``open(configuration:)``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/open(configuration:)) or [``reveal()``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/reveal()) files
- Get sorted children as a stream using [``children(range:)``](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/children(range:)).
- [Typed throws](https://vaida12345.github.io/FinderItem/documentation/finderitem/finderitem/fileerror)


## Getting Started

`FinderItem` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://www.github.com/Vaida12345/FinderItem", from: "1.0.1")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://www.github.com/Vaida12345/FinderItem
```

## Documentation

This package uses [DocC](https://www.swift.org/documentation/docc/) for documentation. [View on Github Pages](https://vaida12345.github.io/FinderItem/documentation/finderitem/)
