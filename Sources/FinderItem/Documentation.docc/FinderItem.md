# ``FinderItem/FinderItem``

## Topics

### Initializers
- ``init(at:)``
- ``init(at:directoryHint:)``
- ``init(from:)-654o7``

### Loading contents

- ``load(_:)-163we``
- <doc:FinderItemLoad>

### Inspecting an item
- ``exists``
- ``fileType-swift.property``

### Inspecting the file path
- ``name``
- ``stem``
- ``extension``
- ``path``
- ``enclosingFolder``
- ``url``
- ``userFriendlyDescription``

### Inspecting the contents
- ``contentType``
- ``contentsEqual(to:)``
- ``setIcon(image:)``
- ``icon(size:)``
- ``preview(size:scale:)``

### Accessing contents of item
- ``itemProvider()``
- ``image()``

### Inspecting a file
- ``isFile``
- ``isDirectory``
- ``isReadable``
- ``isWritable``

### File Operations
- ``copy(to:)``
- ``move(to:)-86edj``
- ``move(to:)-9nixl``
- ``moveToTrash()``
- ``remove()``
- ``removeIfExists()``
- ``clear()``
- ``createSymbolicLink(at:)``

### File Path Operations
- ``appending(path:directoryHint:)``
- ``rename(with:)``
- ``relativePath(to:)``
- ``replacingExtension(with:)``

### Working with Finder
- ``reveal()``
- ``open(configuration:)``

### Working with folder
- ``children(range:)``
- ``ChildrenOption``
- ``FinderItemChildren``

### Making folders
- ``makeDirectory()``
- ``generateDirectory()``
- ``generateOutputPath()``

### Accessing Environment-Dependent Directories
- <doc:FinderItemEnvironment>

### Security Scope
- <doc:FinderItemSecureScope>

### Error Reporting
- ``FileError``

### Deprecated 
- ``fileName``
- ``isExistence``
- ``revealInFinder()``
- ``removeFile()``
- ``removeFileIfExists()``
- ``with(extension:)``
- ``with(subPath:)``
