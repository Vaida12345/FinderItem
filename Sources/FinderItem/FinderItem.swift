//
//  FinderItem.swift
//  The FinderItem Module
//
//  Created by Vaida on 9/18/21.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif
import UniformTypeIdentifiers


/// A representable of files.
///
/// FinderItem in an interface indicating the file on the disk. It is the most convenient way to interact with files.
///
/// Please note that `FinderItem` does not conform to `ObservableObject` as `View`s are not expected to react to change on the path of an item.
///
/// ## File Path
///
/// - A leading `/` would redirect to the root folder, such as */var/*.
/// - A trailing `/` indicates being a folder, such as *folder/*.
///
/// The character `:` is not available in file path, as it is considered as `/`, where `/` is the reserved keyword for the indication of folder. Which means that,
/// - `folder/file.txt` indicates the *file.txt* inside the *folder*.
/// - `folder:file.txt` indicates the *folder/file.txt* file.
///
/// ## Secure Scope
///
/// When one need to persist an user selected file for later usage, the permission for reading is discarded. To prevent this, a bookmark is required. ``FinderItem`` provides this /// functionality using `CodableWithConfiguration`. Instead of encoding the way one would encode some `Codable`, use `configuration` instead.
///
/// ```swift
/// // To encode:
/// try container.encode(item, configuration: [.withSecurityScope])
///
/// // To decode:
/// try container.decode(FinderItem.self, configuration: [.withSecurityScope])
/// ```
///
/// You would still need to call ``FinderItem/tryAccessSecurityScope()`` before and after accessing the file.
///
/// - Experiment: It seems you can only call ``FinderItem/tryAccessSecurityScope()`` on the *original* file, not the ones derived /// using, for example, ``FinderItem/appending(path:directoryHint:)``. This would mean that to access a child folder, you need to /// access the security scope of its parent.
///
/// Certain folders are write-only, for example, even with `com.apple.security.files.downloads.read-write`, there is no way to access /// the contents of Downloads folder created by ``FinderItem/downloadsDirectory``, you need to use a dialog to ask for permission. /// Then, you can access the contents by persisting its bookmark data.
///
/// However, with `com.apple.security.files.downloads.read-write`, it seems you do not need to start security scope to access its /// contents. However, you would still need the bookmark data obtained from the dialog.
///
///
/// ### Bookmarks
///
/// To preserve the access to the security scope, you need to use ``FinderItem/bookmarkData(options:)``. This function returns the /// bookmark data that can be used to create the url with the security scope.
///
/// To create `FinderItem` from the bookmark, use ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``. On return, /// `bookmarkDataIsStale` serves as an indicator of whether the persisted bookmark data needs to be updated.
///
///
/// ### Ask user for permissions
///
/// With `com.apple.security.files.user-selected.read-write`, you could ask users for files using `fileImporter`, or `NSPenal`. /// FinderItem also offers integrated streamline of asking for permission and storing the bookmark. To read more, see /// ``FinderItem/tryPromptAccessFile()``.
///
///
/// ## Topics
///
/// ### Initializers
/// - ``init(at:)``
/// - ``init(at:directoryHint:)``
/// - ``init(from:)-654o7``
///
/// ### Loading contents
///
/// - ``load(_:)-163we``
///
/// ### Inspecting an item
/// - ``exists``
/// - ``fileType-swift.property``
///
/// ### Inspecting the file path
/// - ``name``
/// - ``stem``
/// - ``extension``
/// - ``path``
/// - ``enclosingFolder``
/// - ``url``
/// - ``userFriendlyDescription``
///
/// ### Inspecting the contents
/// - ``contentType``
/// - ``contentsEqual(to:)``
/// - ``setIcon(image:)``
/// - ``icon(size:)``
/// - ``preview(size:scale:)``
///
/// ### Accessing contents of item
/// - ``itemProvider()``
/// - ``image()``
///
/// ### Inspecting a file
/// - ``isFile``
/// - ``isDirectory``
/// - ``isReadable``
/// - ``isWritable``
///
/// ### File Operations
/// - ``copy(to:)``
/// - ``move(to:)-86edj``
/// - ``move(to:)-9nixl``
/// - ``moveToTrash()``
/// - ``remove()``
/// - ``removeIfExists()``
/// - ``clear()``
/// - ``createSymbolicLink(at:)``
///
/// ### File Path Operations
/// - ``appending(path:directoryHint:)``
/// - ``rename(with:)``
/// - ``relativePath(to:)``
/// - ``replacingExtension(with:)``
///
/// ### Working with Finder
/// - ``reveal()``
/// - ``open(configuration:)``
///
/// ### Working with folder
/// - ``children(range:)``
/// - ``ChildrenOption``
/// - ``FinderItemChildren``
///
/// ### Making folders
/// - ``makeDirectory()``
/// - ``generateDirectory()``
/// - ``generateOutputPath()``
///
/// ### Accessing Environment-Dependent Directories
/// - ``FinderItem/applicationSupportDirectory``
/// - ``FinderItem/bundleDirectory``
/// - ``FinderItem/cachesDirectory``
/// - ``FinderItem/currentDirectory``
/// - ``FinderItem/desktopDirectory``
/// - ``FinderItem/documentsDirectory``
/// - ``FinderItem/downloadsDirectory``
/// - ``FinderItem/homeDirectory``
/// - ``FinderItem/libraryDirectory``
/// - ``FinderItem/musicDirectory``
/// - ``FinderItem/moviesDirectory``
/// - ``FinderItem/logsDirectory``
/// - ``FinderItem/picturesDirectory``
/// - ``FinderItem/preferencesDirectory``
/// - ``FinderItem/temporaryDirectory``
/// - ``FinderItem/itemReplacementDirectory``
/// - ``FinderItem/bundleItem(forResource:withExtension:in:)``
///
/// ### Explicitly Handle Security Scope
///
/// - ``FinderItem/tryAccessSecurityScope()``
/// - ``FinderItem/stopAccessSecurityScope()``
/// - ``withAccessingSecurityScopedResource(to:perform:)``
///
///
/// ### Explicitly Handle Bookmark
///
/// - ``FinderItem/bookmarkData(options:)``
/// - ``FinderItem/init(resolvingBookmarkData:options:bookmarkDataIsStale:)``
///
///
/// ### Integrated Security Scope Streamline
/// - ``FinderItem/tryPromptAccessFile()``
///
/// ### Error Reporting
/// - ``FileError``
///
/// ### Deprecated
/// - ``fileName``
/// - ``isExistence``
/// - ``revealInFinder()``
/// - ``removeFile()``
/// - ``removeFileIfExists()``
/// - ``with(extension:)``
/// - ``with(subPath:)``
///
public final class FinderItem: CustomStringConvertible, Hashable, Identifiable, Sendable {
    
    // MARK: - Basic Properties
    
    /// The absolute url.
    nonisolated(unsafe)
    public internal(set) var url: URL
    
    /// Creates the `FinderItem` without standardizing its url.
    internal init(_url: URL) {
        self.url = _url
    }
    
}


public extension FinderItem {
    
    // MARK: - Instance Properties
    
    /// Returns the description of the `FinderItem`.
    @inline(__always)
    var description: String {
        self.path
    }
    
#if os(macOS)
    /// The user friendly description.
    ///
    /// This method would attempt to replace user home directory with "~", and iCloud drive with "iCloud Drive"
    var userFriendlyDescription: String {
        let path = self.path
        let userPath = "/" + FileManager.default.homeDirectoryForCurrentUser.path(percentEncoded: false).split(separator: "/")[0..<2].joined(separator: "/")
        
        if path.hasPrefix(userPath) {
            let path = path.replacing(userPath, with: "~", maxReplacements: 1)
            
            if path.hasPrefix("~/Library/Mobile Documents/com~apple~CloudDocs") {
                return path.replacing("~/Library/Mobile Documents/com~apple~CloudDocs", with: "iCloud Drive", maxReplacements: 1)
            } else {
                return path
            }
        } else {
            return path
        }
    }
#endif
    
    /// The parent folder for the current item.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "folder/file.txt")
    /// > item.enclosingFolder // "folder/"
    /// > ```
    @inline(__always)
    var enclosingFolder: FinderItem {
        FinderItem(_url: self.url.deletingLastPathComponent())
    }
    
    /// The textual path of the given item.
    @inline(__always)
    var path: String {
        self.url.path(percentEncoded: false)
    }
    
    /// The full name of the file.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "folder/file.txt")
    /// > item.name // "file.txt"
    /// > ```
    ///
    /// - seeAlso: ``rename(with:)``, ``stem``, ``extension``
    @inline(__always)
    var name: String {
        self.url.lastPathComponent
    }
    
    /// The extension name of the file.
    ///
    /// - Note: The extension name is the `String` after `.`. The value can be empty, which indicates being a folder.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "folder/file.txt")
    /// > item.extension // "txt"
    /// > ```
    ///
    /// - SeeAlso: ``rename(with:)``.
    @inlinable
    var `extension`: String {
        self.url.pathExtension
    }
    
    /// The non-extension part of the file name.
    ///
    /// The file name is the `String` before `.`.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "folder/file.txt")
    /// > item.fileName // "file"
    /// > ```
    ///
    /// - Invariant: The stem is considered as the part before the extension. For example, stem of `file.tar.gz` is `file.tar`. The connotation of ``stem``, `.` and ``extension`` is always ``name``.
    ///
    /// - SeeAlso: ``rename(with:)``, ``extension``, ``name``
    @inlinable
    var stem: String {
        let name = self.name
        guard let lastIndex = name.lastIndex(of: ".") else { return name }
        return String(name[name.startIndex..<lastIndex])
    }
    
    /// The non-extension part of the file name.
    @available(*, deprecated, renamed: "stem")
    @inline(__always)
    var fileName: String { self.stem }
    
    /// Determines whether a `item` is a directory (instead of file).
    ///
    /// This method would consult the file system for the nature of the file. If the file does not exist, it would fall back to `hasDirectoryPath` as indicated in ``init(at:directoryHint:)``.
    ///
    /// - Returns: `false` if the file does not exists.
    @inline(__always)
    var isDirectory: Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? self.url.hasDirectoryPath
    }
    
    /// Determines whether a `item` is a file (instead of directory).
    ///
    /// This method would consult the file system for the nature of the file. If the file does not exist, it would fall back to `hasDirectoryPath` as indicated in ``init(at:directoryHint:)``.
    ///
    /// - Returns: `false` if the file does not exists.
    @inline(__always)
    var isFile: Bool {
        (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? !self.url.hasDirectoryPath
    }
    
    /// Returns the file type of the given file.
    ///
    /// To inspect the content,
    ///
    /// ```swift
    /// item.fileType.contains(.package)
    /// ```
    ///
    /// ## Topics
    /// ### The Resulting Structure
    /// - ``FileType-swift.struct``
    var fileType: FileType {
        get throws(FileError) {
            do {
                let sourceKeys: Set<URLResourceKey> = [.isRegularFileKey, .isDirectoryKey, .isApplicationKey, .isAliasFileKey, .isPackageKey, .isHiddenKey, .isSymbolicLinkKey]
                let resourceValues = try self.url.resourceValues(forKeys: sourceKeys)
                var types: FileType = []
                
                if resourceValues.isRegularFile  ?? false { types.formUnion(.file) }
                if resourceValues.isDirectory    ?? false { types.formUnion(.directory) }
                if resourceValues.isApplication  ?? false { types.formUnion(.application) }
                if resourceValues.isAliasFile    ?? false { types.formUnion(.alias) }
                if resourceValues.isPackage      ?? false { types.formUnion(.package) }
                if resourceValues.isHidden       ?? false { types.formUnion(.hidden) }
                if resourceValues.isSymbolicLink ?? false { types.formUnion(.symbolicLink) }
                
                return types
            } catch {
                throw try FileError.parse(error)
            }
        }
    }
    
    /// The `UTType` of the file.
    @inline(__always)
    var contentType: UTType? {
        get throws(FileError) {
            do {
                return try url.resourceValues(forKeys: [.contentTypeKey]).contentType
            } catch {
                throw try FileError.parse(error)
            }
        }
    }
    
    /// Determines whether the file exists at the required position.
    @available(*, deprecated, renamed: "exists")
    @inline(__always)
    var isExistence: Bool {
        self.exists
    }
    
    /// Determines whether the file exists at the required position.
    @inline(__always)
    var exists: Bool {
        FileManager.default.fileExists(atPath: self.path)
    }
    
    /// Determines whether the file is writable.
    @inline(__always)
    var isWritable: Bool {
        (try? self.url.resourceValues(forKeys: [.isWritableKey]).isWritable) ?? false
    }
    
    /// Determines whether the file is readable.
    @inline(__always)
    var isReadable: Bool {
        (try? self.url.resourceValues(forKeys: [.isReadableKey]).isReadable) ?? false
    }
    
    
    // MARK: - Initializers
    
    /// Creates an instance with an **absolute** url.
    ///
    /// The input `url` will be standardized.
    ///
    /// ```swift
    /// FinderItem(at: "/Users/vaida/Desktop")
    /// // The url is /Users/vaida/Desktop/
    /// ```
    ///
    /// - Parameters:
    ///   - url: The absolute ``url``.
    @inline(__always)
    convenience init(at url: URL) {
        self.init(_url: url)
    }
    
    /// Creates the `FinderItem` without standardizing its url.
    @inline(__always)
    internal convenience init(_path: String, directoryHint: URL.DirectoryHint) {
        self.init(_url: URL(filePath: _path, directoryHint: directoryHint).standardizedFileURL)
    }
    
    /// Creates an instance with an absolute path.
    ///
    /// Here is an [example table](https://forums.swift.org/t/back-from-revision-foundation-url-improvements/54605#the-new-directoryhint-type) of how the `directoryHint` works.
    ///
    /// | `path`          | `directoryHint`   | `hasDirectoryPath`  |
    /// |-----------------|-------------------|---------------------|
    /// | `/file`         | `inferFromPath`   | `false`             |
    /// | `/directory/`   | `inferFromPath`   | `true`              |
    /// | `/test/apple`   | `isDirectory`     | `true`              |
    /// | `/test/apple`   | `isNotDirectory`  | `false`             |
    /// | `lib.framework` | `checkFileSystem` | `false`             |
    ///
    /// Nevertheless, in the current implementations, the ``isDirectory`` method consults the file system, and use `hasDirectoryPath` as a fallback.
    ///
    /// > Note:
    /// > The input `path` will be standardized.
    /// >
    /// > ```swift
    /// > FinderItem(at: "/Users/vaida/Desktop")
    /// > // The url is /Users/vaida/Desktop/
    /// > ```
    ///
    /// - Important: The initializer is unable to process paths starting with a tilde `~`.
    ///
    /// - Parameters:
    ///   - path: The absolute path. A `/` should be added to the end as an indication of being a folder.
    ///   - directoryHint: An indication of whether the given path is an directory. This would effect the `hasDirectoryPath` value of the underlining ``url``.
    @inlinable
    convenience init(at path: String, directoryHint: URL.DirectoryHint = .inferFromPath) {
        self.init(at: URL(filePath: path, directoryHint: directoryHint))
    }
    
    /// Creates an instance with a provider.
    ///
    /// - Parameters:
    ///   - provider: The `NSItemProvider` which contains the file-url of the item.
    convenience init(from provider: NSItemProvider) async throws {
        let url: URL = try await withCheckedThrowingContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { data, error in
                guard error == nil else { continuation.resume(throwing: error!); return }
                
                guard let urlData = data as? Data else { continuation.resume(throwing: CocoaError(.coderReadCorrupt)); return }
                guard let url = URL(dataRepresentation: urlData, relativeTo: nil) else { continuation.resume(throwing: CocoaError(.coderReadCorrupt)); return }
                continuation.resume(returning: url)
            }
        }
        
        self.init(_url: url)
    }
    
    
    // MARK: - Instance Methods
    
    /// Copies the current item to the `destination`.
    ///
    /// - Note: It creates the required folders at the copied item path.
    ///
    /// - Warning: This method removes the file at the destination.
    ///
    /// - Parameters:
    ///   - destination: The ``FinderItem`` where the current item is copied to.
    @inlinable
    func copy(to destination: FinderItem) throws(FileError) {
        do {
            if !destination.enclosingFolder.exists {
                try destination.enclosingFolder.makeDirectory()
            } else {
                try destination.removeIfExists()
            }
            
            try FileManager.default.copyItem(at: self.url, to: destination.url)
        } catch {
            throw try FileError.parse(error)
        }
    }
    
    /// Creates a symbolic link at the specified URL that points to an item at the given URL.
    ///
    /// - Parameters:
    ///   - item: The file URL at which to create the new symbolic link. The last path component of the URL issued as the name of the link.
    @inlinable
    func createSymbolicLink(at item: FinderItem) throws(FileError) {
        do {
            try FileManager.default.createSymbolicLink(at: item.url, withDestinationURL: self.url)
        } catch {
            throw try FileError.parse(error)
        }
    }
    
    /// Clears the content in the directory of the instance.
    ///
    /// - Note: This was done by enumerating and deleting each child.
    @inlinable
    func clear() throws(FileError) {
        do {
            for child in try self.children(range: .contentsOfDirectory.withSystemHidden) {
                try child.remove()
            }
        } catch {
            throw try FileError.parse(error)
        }
    }
    
    /// Returns a Boolean value that indicates whether the files or directories in specified paths have the same contents.
    ///
    /// If both are directories, the contents are the list of files and subdirectories each contains—contents of subdirectories are also compared. For files, this method checks to see if they’re the same file, then compares their size, and finally compares their contents. This method does not traverse symbolic links, but compares the links themselves.
    ///
    /// - Parameters:
    ///   - other: The path of a file or directory to compare with the contents of this item.
    ///
    /// - Returns: true if file or directory specified in path1 has the same contents as that specified in path2, otherwise false.
    @inlinable
    func contentsEqual(to other: FinderItem) -> Bool {
        FileManager.default.contentsEqual(atPath: self.url.path(percentEncoded: false), andPath: other.url.path(percentEncoded: false))
    }
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.url)
    }
    
    /// Generates the desired folders at the path, context ignored.
    ///
    /// - throws: When cannot create a directory, or a file with the same name exists.
    ///
    /// - SeeAlso: To generate the directory *smartly*, ``generateDirectory()``
    @inlinable
    func makeDirectory() throws(FileError) {
        guard !self.exists else {
            if self.isFile {
                throw FileError(code: .cannotWrite(reason: .fileExists), source: self)
            } else {
                return // must be directory, return.
            }
        }
        
        do {
            try FileManager.default.createDirectory(at: self.url, withIntermediateDirectories: true)
            // no need for the loops, `withIntermediateDirectories` does all the works
        } catch {
            throw try FileError.parse(error)
        }
    }
    
    /// Generates the desired folders at the path, context-aware.
    ///
    /// This function should only be used when one is unsure whether a folder should be generated for its ``enclosingFolder`` or itself. A simple parser will be used to determine its nature. Otherwise, use ``makeDirectory()`` instead.
    ///
    /// - SeeAlso: To generate the directory robustly, ``makeDirectory()``
    @inlinable
    func generateDirectory() throws(FileError) {
        let targetIsFolder = self.url.hasDirectoryPath
        if targetIsFolder {
            try self.makeDirectory()
        } else {
            try self.enclosingFolder.makeDirectory()
        }
    }
    
    /// Changes the ``url`` so that there is no file of the same name on disk.
    ///
    /// - Warning: This method changes the ``url``, along with path to the actual file on the disk.
    ///
    /// - Note: This method was designed to fit the situation when there would be multiple files of the same name at a location.
    func generateOutputPath() throws(FileError) {
        guard self.exists else { try self.enclosingFolder.makeDirectory(); return }
        
        var counter = 2
        var stem = self.stem
        
        if let lastIndex = stem.lastIndex(of: " "), let index = Int(stem[stem.index(after: lastIndex)..<stem.endIndex]) {
            counter = index
            stem = String(stem[stem.startIndex..<lastIndex])
        } else if let index = Int(stem) {
            stem = ""
            counter = index
        }
        
        if !stem.isEmpty {
            stem += " "
        }
        
        let enclosingFolder = self.enclosingFolder
        let extensionName = self.extension
        
        if !extensionName.isEmpty {
            while enclosingFolder.appending(path: "\(stem)\(counter).\(extensionName)").exists {
                counter += 1
            }
            
            self.url = enclosingFolder.appending(path: "\(stem)\(counter).\(extensionName)").url
        } else {
            while enclosingFolder.appending(path: "\(stem)\(counter)").exists {
                counter += 1
            }
            self.url = enclosingFolder.appending(path: "\(stem)\(counter)").url
        }
    }
    
#if !os(watchOS) && !os(tvOS)
    /// Moves the current item to trash.
    ///
    /// - Warning: This method changes the ``url``, along with path to the actual file on the disk.
    func moveToTrash() throws(FileError) {
        do {
            var newURL: NSURL?
            try FileManager.default.trashItem(at: self.url, resultingItemURL: &newURL)
            guard let url = newURL else { return }
            self.url = url as URL
        } catch {
            throw try FileError.parse(error)
        }
    }
#endif
    
    /// Move the current item to `url`.
    ///
    /// - Warning: This method changes the ``url``, along with path to the actual file on the disk.
    ///
    /// - Parameters:
    ///   - url: The destination `url`.
    ///
    /// - Note: The destination is overwritten.
    func move(to url: URL) throws(FileError) {
        guard url != self.url else { return }
        do {
            try FileManager.default.moveItem(at: self.url, to: url)
            self.url = url
        } catch {
            throw try FileError.parse(error)
        }
    }
    
    /// Move the current item to `path`.
    ///
    /// - Warning: This method changes the ``url``, along with path to the actual file on the disk.
    ///
    /// - Parameters:
    ///   - path: The destination `path`.
    func move(to path: String) throws(FileError) {
        try self.move(to: URL(filePath: path))
    }
    
    /// Returns the relative path to other `item`.
    ///
    /// ```swift
    /// let folder = FinderItem(at: "folder/")
    /// let file = FinderItem(at: "folder/file")
    /// file.relativePath(to: folder) // file
    /// ```
    ///
    /// - Attention: The return value is `nil` if current instance is not in the folder of `item`.
    ///
    /// - Parameters:
    ///   - item: A folder that hoped to contain current instance.
    ///
    /// - Returns: The relative path to other item; `nil` otherwise.
    @inlinable
    func relativePath(to item: FinderItem) -> String? {
        let selfPath = self.url.path(percentEncoded: false)
        let itemPath = item.url.path(percentEncoded: false)
        guard selfPath.hasPrefix(itemPath) else { return nil }
        
        var value = selfPath.dropFirst(itemPath.count)
        if value.hasPrefix("/") {
            value.removeFirst()
        }
        return String(value)
    }
    
    /// Remove the file.
    @available(*, deprecated, renamed: "remove")
    @inlinable
    func removeFile() throws(FileError) {
        try self.remove()
    }
    
    /// Remove the file.
    ///
    /// - Note: Although the file is removed, the ``url`` remains unchanged.
    @inlinable
    func remove() throws(FileError) {
        do {
            try FileManager.default.removeItem(at: self.url)
        } catch {
            throw try FileError.parse(error)
        }
    }
    
    /// Remove the file if it exists.
    @available(*, deprecated, renamed: "removeIfExists")
    @inlinable
    func removeFileIfExists() throws(FileError) {
        try self.removeIfExists()
    }
    
    /// Remove the file if it exists.
    ///
    /// - Note: Although the file is removed, the ``url`` remains unchanged.
    @inlinable
    func removeIfExists() throws(FileError) {
        guard self.exists else { return }
        try self.remove()
    }
    
    /// Renames the file.
    ///
    /// ```swift
    /// let item: FinderItem = .desktopDirectory.with(subPath: "123.png")
    /// item.rename(with: "456.png")
    /// ```
    ///
    /// - Warning: This method changes the ``url``, and filePath of the actual file on the disk.
    ///
    /// - Important: Any changes to the ``name`` should call this method to sync content on disk.
    ///
    /// - Experiment: The function returns before the file on disk is renamed. However, ``path`` is correct as the function would update it with code.
    ///
    /// - Parameters:
    ///   - newName: The ``name`` for the file.
    ///   - keepExtension: If `true`, the extension would be appended at the end of `newName`.
    ///
    /// - Note: The destination is overwritten.
    func rename(with newName: String, keepExtension: Bool = false) throws(FileError) {
        guard !newName.isEmpty else {
            fatalError("Attempting to rename the file with an empty name.")
        }
        
        let extensionName: String
        if keepExtension {
            let _extension = self.extension
            if _extension.isEmpty {
                extensionName = ""
            } else {
                extensionName = "." + _extension
            }
        } else {
            extensionName = ""
        }
        
        try self.move(to: self.enclosingFolder.appending(path: newName + extensionName).url)
    }
    
    /// Returns a new instance with the path of its child.
    ///
    /// Here is an [example table](https://forums.swift.org/t/back-from-revision-foundation-url-improvements/54605#the-new-directoryhint-type) of how the `directoryHint` works.
    ///
    /// | `path`          | `directoryHint`   | `hasDirectoryPath`  |
    /// |-----------------|-------------------|---------------------|
    /// | `/file`         | `inferFromPath`   | `false`             |
    /// | `/directory/`   | `inferFromPath`   | `true`              |
    /// | `/test/apple`   | `isDirectory`     | `true`              |
    /// | `/test/apple`   | `isNotDirectory`  | `false`             |
    /// | `lib.framework` | `checkFileSystem` | `false`             |
    ///
    /// Nevertheless, in the current implementations, the ``isDirectory`` method consults the file system, and use `hasDirectoryPath` as a fallback.
    ///
    /// ```swift
    /// let item = FinderItem(at: "folder/")
    /// item.appending(path: "file.txt") // "folder/file"
    /// ```
    ///
    /// - Note: The `path` can either begin with `"/"` or not.
    ///
    /// - Parameters:
    ///   - path: The relative path. A `/` should be added to the end as an indication of being a folder.
    ///   - directoryHint: An indication of whether the given path is an directory. This would effect the `hasDirectoryPath` value of the underlining ``url``.
    ///
    /// - Returns: A new instance with the path of its child.
    @inlinable
    func appending(path: some StringProtocol, directoryHint: URL.DirectoryHint = .inferFromPath) -> FinderItem {
        guard !path.isEmpty else { return self }
        return FinderItem(at: self.url.appending(path: path, directoryHint: directoryHint))
    }
    
    @available(*, deprecated, renamed: "appending(path:)")
    @inlinable
    func with(subPath: some StringProtocol) -> FinderItem {
        self.appending(path: subPath)
    }
    
    /// Returns a new instance with the path by replacing the extension with the new value.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "file.txt")
    /// > item.replacingExtension(with: "png") // "file.png"
    /// > ```
    ///
    /// - Note: `extension` can be empty, which indicates no extension.
    ///
    /// - invariant: This does not include any file operations.
    ///
    /// - Parameters:
    ///   - extensionName: The new extension name.
    @inlinable
    func replacingExtension(with extensionName: some StringProtocol) -> FinderItem {
        let name = extensionName as? String ?? String(extensionName)
        return self.enclosingFolder.appending(path: name.isEmpty ? self.stem : self.stem + "." + name)
    }
    
    /// Returns a new instance with the path by replacing the extension with the new value.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "file.txt")
    /// > item.with(extension: "png") // "file.png"
    /// > ```
    ///
    /// - Note: `extension` can be empty, which indicates no extension.
    ///
    /// - Parameters:
    ///   - name: The new extension name.
    @inlinable
    @available(*, deprecated, renamed: "replacingExtension(with:)")
    func with(extension name: some StringProtocol) -> FinderItem {
        self.replacingExtension(with: name)
    }
    
    
    // MARK: - Type Methods
    
    /// Returns the item for the resource by the name in the app's ``bundleDirectory``.
    ///
    /// - Parameters:
    ///   - name: The name of the resource file.
    ///   - ext: The extension of the resource file.
    ///   - bundle: The bundle in which the file exists.
    ///
    /// - Returns: The ``FinderItem`` for the resource file or `nil` if the file could not be located.
    @inlinable
    class func bundleItem(forResource name: String, withExtension ext: String, in bundle: Bundle = .main) -> FinderItem? {
        guard let url = bundle.url(forResource: name, withExtension: ext) else { return nil }
        return FinderItem(at: url)
    }
    
    /// Returns the normalized path from the given shell path.
    @inlinable
    class func normalize(shellPath: String, shouldRemoveTrailingSpace: Bool = true) -> String {
        var path = shellPath
            .replacingOccurrences(of: "\\ ", with: " ")
            .replacingOccurrences(of: #"\("#, with: "(")
            .replacingOccurrences(of: #"\)"#, with: ")")
            .replacingOccurrences(of: #"\["#, with: "[")
            .replacingOccurrences(of: #"\]"#, with: "]")
            .replacingOccurrences(of: #"\{"#, with: "{")
            .replacingOccurrences(of: #"\}"#, with: "}")
            .replacingOccurrences(of: #"\`"#, with: "`")
            .replacingOccurrences(of: #"\~"#, with: "~")
            .replacingOccurrences(of: #"\!"#, with: "!")
            .replacingOccurrences(of: #"\@"#, with: "@")
            .replacingOccurrences(of: "\\#", with: "#")
            .replacingOccurrences(of: #"\$"#, with: "$")
            .replacingOccurrences(of: #"\%"#, with: "%")
            .replacingOccurrences(of: #"\&"#, with: "&")
            .replacingOccurrences(of: #"\*"#, with: "*")
            .replacingOccurrences(of: #"\="#, with: "=")
            .replacingOccurrences(of: #"\|"#, with: "|")
            .replacingOccurrences(of: #"\;"#, with: ";")
            .replacingOccurrences(of: #"\""#, with: #"""#)
            .replacingOccurrences(of: #"\'"#, with: #"'"#)
            .replacingOccurrences(of: #"\<"#, with: "<")
            .replacingOccurrences(of: #"\>"#, with: ">")
            .replacingOccurrences(of: #"\,"#, with: ",")
            .replacingOccurrences(of: #"\?"#, with: "?")
            .replacingOccurrences(of: #"\\"#, with: #"\"#)
        
        if shouldRemoveTrailingSpace && path.hasSuffix(" ") {
            path.removeLast()
        }
        
        return path
    }
    
    // MARK: - enums
    
    /// The type of the item.
    struct FileType: OptionSet, Sendable {
        
        public let rawValue: Int
        
        /// determining whether the resource is a regular file rather than a directory or a symbolic link.
        public static let file         = FileType(rawValue: 1 << 0)
        /// determining whether the resource is a directory
        public static let directory    = FileType(rawValue: 1 << 1)
        /// determining whether the resource is an application
        public static let application  = FileType(rawValue: 1 << 2)
        /// determining whether the file is an alias.
        public static let alias        = FileType(rawValue: 1 << 3)
        /// determining whether the resource is a file package.
        public static let package      = FileType(rawValue: 1 << 4)
        /// determining whether the resource is normally not displayed to users
        public static let hidden       = FileType(rawValue: 1 << 5)
        /// determining whether the resource is a symbolic link
        public static let symbolicLink = FileType(rawValue: 1 << 5)
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
    }
    
}
