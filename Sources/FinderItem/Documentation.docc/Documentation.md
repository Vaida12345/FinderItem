# ``FinderItem``

The FinderItem Package.


## Overview

The ``FinderItem/FinderItem`` provides a great abstraction over the ways in which you can interact with the file system.


## Getting Started

`FinderItem` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(name: "FinderItem", 
             path: "~/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/FinderItem")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
~/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Packages/FinderItem
```
