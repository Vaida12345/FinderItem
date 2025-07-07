# ``FinderItem/FinderItem``

## Overview

FinderItem abstracts over many structures, including `FileManager`, `URL`, `FilePath`, and more.

As a basic example, you can use ``children(range:)`` to print all files on your desktop.
```swift
import FinderItem

let desktop = FinderItem.desktopDirectory
for child in try desktop.children(range: .contentsOfDirectory) {
    print(child)
}
```

### Path & String

You can quickly initialize a `FinderItem` using a `String`.
```swift
let midis: FinderItem = "/Users/johnny/Desktop/MIDIs/"
```

- Note: The trailing `/` tells the file system that this file is a directory, [read more](<doc:filepath>).

Using ``/(_:_:)``, you can jump to a child. 
```swift
let best = midis/"favorite.mid"
```

### Accessing Content
To access the contents of file, use the unified ``load(_:)`` method.
```swift
let text = try file.load(.string())
```


## Topics

### Initializers
- ``init(at:)``
- ``init(at:directoryHint:)``

### Loading contents
- ``load(_:)-7spks``

### Inspecting a file
- ``exists``
- ``isFile``
- ``isDirectory``


### Inspecting the file path
- ``name``
- ``stem``
- ``extension``
- ``path``
- ``enclosingFolder``
- ``url``
- ``userFriendlyDescription``
- ``normalize(shellPath:shouldRemoveTrailingSpace:)``

### Inspecting the contents
- ``contentType``
- ``contentsEqual(to:)``

### File Operations
File operations will change the location of the actual file it represents.
- ``copy(to:)``
- ``move(to:)-3wp1t``
- ``moveToTrash()``
- ``remove()``
- ``removeIfExists()``
- ``clear()``
- ``createSymbolicLink(at:)``
- ``resolvingAlias(options:)``

### Error Reporting
- ``FileError``

### File Path Operations
- ``/(_:_:)``
- ``appending(path:directoryHint:)``
- ``rename(with:keepExtension:)``
- ``relativePath(to:)``
- ``replacingStem(with:)``
- ``replacingExtension(with:)``
- ``generateUniquePath()``

### Working with Finder
- ``reveal()``
- ``open()``
- ``setIcon(image:)``

### Working with directories
- ``children(range:)``
- ``ChildrenRange``
- ``FinderItemChildren``
- ``makeDirectory()``
- ``generateDirectory()``

### Working with Environment-Dependent Directories
- <doc:environment>

### Working with security scope
- <doc:securescope>

### File Attributes
- ``load(_:)``
- ``insertAttribute(_:_:)``

### Integrations
Technology-specific implementations.
- ``ValueTransformer``

### Deprecated
- <doc:deprecated>
- <doc:legacy>
