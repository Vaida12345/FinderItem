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


/// Abstractions over which you interact with file system.
public final class FinderItem: CustomStringConvertible, Hashable, Identifiable, @unchecked Sendable {
    
    // MARK: - Basic Properties
    
    /// The absolute url.
    public internal(set) var url: URL
    
    /// Creates the `FinderItem` without standardizing its url.
    @usableFromInline
    internal init(_url: URL) {
        self.url = _url
    }
    
}


public extension FinderItem {
    
    // MARK: - Instance Properties
    
    /// Returns the description of the `FinderItem`.
    @inlinable
    var description: String {
        self.path
    }
    
#if os(macOS)
    /// The user friendly description.
    ///
    /// This method would attempt to replace user home directory with "~", and iCloud drive with "iCloud Drive"
    @inlinable
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
    @inlinable
    var enclosingFolder: FinderItem {
        FinderItem(_url: self.url.deletingLastPathComponent())
    }
    
    /// The textual path of the given item.
    ///
    /// [Learn More](<doc:filepath>)
    @inlinable
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
    /// - seeAlso: ``rename(with:keepExtension:)``, ``stem``, ``extension``
    @inlinable
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
    /// - SeeAlso: ``rename(with:keepExtension:)``.
    @inlinable
    var `extension`: String {
        self.url.pathExtension
    }
    
    /// The non-extension part of the file name.
    ///
    /// The file name is the `String` before the last `.`.
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
    /// - SeeAlso: ``rename(with:keepExtension:)``, ``extension``, ``name``
    @inlinable
    var stem: String {
        let name = self.name
        guard let lastIndex = name.lastIndex(of: ".") else { return name }
        return String(name[name.startIndex..<lastIndex])
    }
    
    /// The non-extension part of the file name.
    @available(*, deprecated, renamed: "stem")
    @inlinable
    var fileName: String { self.stem }
    
    /// Determines whether a `item` is a directory (instead of file).
    ///
    /// This method would consult the file system for the nature of the file. If the file does not exist, it would fall back to `hasDirectoryPath` as indicated in ``init(at:directoryHint:)``.
    ///
    /// - Returns: If the file does not exist, it is inferred from the ``url``.
    @inlinable
    var isDirectory: Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? self.url.hasDirectoryPath
    }
    
    /// Determines whether a `item` is a file (instead of directory).
    ///
    /// This method would consult the file system for the nature of the file. If the file does not exist, it would fall back to `hasDirectoryPath` as indicated in ``init(at:directoryHint:)``.
    ///
    /// - Returns: If the file does not exist, it is inferred from the ``url``.
    @inlinable
    var isFile: Bool {
        (try? url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) ?? !self.url.hasDirectoryPath
    }
    
    /// The `UTType` of the file.
    @inlinable
    var contentType: UTType {
        get throws(FileError) {
            do {
                guard let contentType = try url.resourceValues(forKeys: [.contentTypeKey]).contentType else { throw FileError(code: .cannotRead(reason: .resourceValueNotAvailable), source: self) }
                return contentType
            } catch {
                throw FileError.parse(error)
            }
        }
    }
    
    /// Determines whether the file exists at the required position.
    @available(*, deprecated, renamed: "exists")
    @inlinable
    var isExistence: Bool {
        self.exists
    }
    
    /// Determines whether the file exists at the required position.
    @inlinable
    var exists: Bool {
        FileManager.default.fileExists(atPath: self.path)
    }
    
    /// The id, which is its ``url``.
    @inlinable
    var id: URL {
        self.url
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
    @inlinable
    convenience init(at url: URL) {
        self.init(_url: url)
    }
    
    /// Creates the `FinderItem` without standardizing its url.
    @inlinable
    internal convenience init(_path: String, directoryHint: URL.DirectoryHint) {
        self.init(_url: URL(filePath: _path, directoryHint: directoryHint))
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
    /// [Learn More](<doc:filepath>)
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
        self.init(at: URL(filePath: path, directoryHint: directoryHint).standardizedFileURL)
    }
    
    /// Creates an instance with a provider.
    ///
    /// - Parameters:
    ///   - provider: The `NSItemProvider` which contains the file-url of the item.
    @inlinable
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
    
    /// Creates a symbolic link at the specified URL that points to `self`.
    ///
    /// - Parameters:
    ///   - item: The file URL at which to create the new symbolic link. The last path component of the URL issued as the name of the link.
    @inlinable
    func createSymbolicLink(at item: FinderItem) throws(FileError) {
        do {
            try FileManager.default.createSymbolicLink(at: item.url, withDestinationURL: self.url)
        } catch {
            throw FileError.parse(error)
        }
    }
    
    /// Clears the content in the directory of the instance.
    ///
    /// - Note: This is done by enumerating and deleting each child.
    @inlinable
    func clear() throws(FileError) {
        do {
            for child in try self.children(range: .contentsOfDirectory.withSystemHidden) {
                try child.remove()
            }
        } catch {
            throw FileError.parse(error)
        }
    }
    
    /// Indicates whether the files or directories in specified path has the same contents with `self`.
    ///
    /// If both are directories, the contents are the list of files and subdirectories each contains—contents of subdirectories are also compared. For files, this method checks to see if they’re the same file, then compares their size, and finally compares their contents. This method does not traverse symbolic links, but compares the links themselves.
    ///
    /// - Parameters:
    ///   - other: The path of a file or directory to compare with `self`.
    @inlinable
    func contentsEqual(to other: FinderItem) -> Bool {
        FileManager.default.contentsEqual(atPath: self.url.path(percentEncoded: false), andPath: other.url.path(percentEncoded: false))
    }
    
    /// Generates the desired folder at the given path.
    ///
    /// - throws: When cannot create a directory, or a file with the same name exists.
    ///
    /// - SeeAlso: To generate the directory *smartly*, use ``generateDirectory()``
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
            throw FileError.parse(error)
        }
    }
    
    /// Generates the desired folders at the path, context-aware.
    ///
    /// This function should be employed only when there is uncertainty about whether a folder should be generated for its ``enclosingFolder`` or for the folder itself. A simple parser will be utilized to determine its nature. If this is not the case, the ``makeDirectory()`` function should be used instead.
    ///
    /// The nature is determined using `hasDirectoryPath` as indicated in ``init(at:directoryHint:)``.
    @inlinable
    func generateDirectory() throws(FileError) {
        let targetIsFolder = self.url.hasDirectoryPath
        if targetIsFolder {
            try self.makeDirectory()
        } else {
            try self.enclosingFolder.makeDirectory()
        }
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
    /// - Returns: The relative path to other item; `nil` otherwise. The leading `/` is trimmed.
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
    /// - Note: Although the file is removed, the internal representation (``url``) remains unchanged.
    ///
    /// - Experiment: The file is removed on return.
    @inlinable
    func remove() throws(FileError) {
        do {
            try FileManager.default.removeItem(at: self.url)
        } catch {
            throw FileError.parse(error)
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
    /// - Note: Although the file is removed, the internal representation (``url``) remains unchanged.
    ///
    /// - Experiment: The file is removed on return.
    @inlinable
    func removeIfExists() throws(FileError) {
        guard self.exists else { return }
        try self.remove()
    }
    
    /// Returns the ``FinderItem`` that refers to the location specified by resolving an alias file.
    ///
    /// If `self` isn't an alias file, the returned item is the same as `self`.
    ///
    /// This method throws an error in the following cases:
    /// - The url argument is unreachable.
    /// - The original file or directory is unknown or unreachable.
    /// - The original file or directory is on a volume that the system can’t locate or can’t mount.
    ///
    /// This method doesn’t support the `withSecurityScope` option.
    @inlinable
    func resolvingAlias(options: URL.BookmarkResolutionOptions = []) throws(FileError) -> FinderItem {
        do {
            return try FinderItem(_url: URL(resolvingAliasFileAt: self.url, options: options))
        } catch {
            throw FileError.parse(error)
        }
    }
    
    /// Hashes the essential components of this value by feeding them into the given hasher.
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.url)
    }
    
    
    // MARK: - File Operations
    
    /// Copies the current item to the `destination`.
    ///
    /// Any necessary folders required to store the `destination` are automatically created.
    ///
    /// - Parameters:
    ///   - destination: The ``FinderItem`` where the current item is copied to.
    @inlinable
    func copy(to destination: FinderItem) throws(FileError) {
        do {
            if !destination.enclosingFolder.exists {
                try destination.enclosingFolder.makeDirectory()
            }
            
            try FileManager.default.copyItem(at: self.url, to: destination.url)
        } catch {
            throw FileError.parse(error)
        }
    }
    
#if !os(watchOS) && !os(tvOS)
    /// Moves the current item to trash.
    ///
    /// This is a file operation. As a ``FinderItem`` is linked to the item it references, the internal representation (``url``) is modified upon the function's return.
    ///
    /// - Experiment: The file is moved before return.
    func moveToTrash() throws(FileError) {
        do {
            var newURL: NSURL?
            try FileManager.default.trashItem(at: self.url, resultingItemURL: &newURL)
            guard let url = newURL else { return }
            self.url = url as URL
        } catch {
            throw FileError.parse(error)
        }
    }
#endif
    
    /// Move the current item to `url`.
    ///
    /// - Parameters:
    ///   - destination: The destination `url`.
    ///
    /// This is a file operation. As a ``FinderItem`` is linked to the item it references, the internal representation (``url``) is changed to `destination` upon the function's return.
    ///
    /// - Tip: To change the file path itself, rather than the file, use ``replacingStem(with:)`` or ``replacingExtension(with:)``.
    ///
    /// - Experiment: The file is moved before return.
    func move(to destination: URL) throws(FileError) {
        guard destination != self.url else { return }
        do {
            try FileManager.default.moveItem(at: self.url, to: destination)
            self.url = destination
        } catch {
            throw FileError.parse(error)
        }
    }
    
    /// Move the current item to `path`.
    ///
    /// This is a file operation. As a ``FinderItem`` is linked to the item it references, the internal representation (``url``) is changed to `destination` upon the function's return.
    ///
    /// - Parameters:
    ///   - destination: The destination `path`.
    ///
    /// ## Topics
    /// ### Variants
    /// - ``FinderItem/move(to:)-8seqh``
    ///
    /// - Experiment: The file is moved before return.
    @inlinable
    func move(to destination: String) throws(FileError) {
        try self.move(to: URL(filePath: destination))
    }
    
    /// Renames the file.
    ///
    /// This is a file operation. As a ``FinderItem`` is linked to the item it references, the internal representation (``url``) is modified upon the function's return.
    ///
    /// - Parameters:
    ///   - newName: The ``name`` for the file.
    ///   - keepExtension: If `true`, the extension would be appended at the end of `newName`.
    ///
    /// - Tip: To change the file path itself, rather than the file, use ``replacingStem(with:)`` or ``replacingExtension(with:)``.
    ///
    /// - Precondition: `newName` cannot be empty.
    ///
    /// - Experiment: The file is moved before return.
    @inlinable
    func rename(with newName: String, keepExtension: Bool = false) throws(FileError) {
        precondition(!newName.isEmpty, "The `newName` cannot be empty.")
        
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
    
    
    // MARK: - File Path Operations
    
    /// Changes the ``url`` so that there is no file of the same name on disk.
    ///
    /// - Warning: This method changes the ``url``.
    ///
    /// - Note: This method was designed to fit the situation when there would be multiple files of the same name at a location.
    ///
    /// > Example:
    /// >
    /// > ```swift
    /// > let item = FinderItem(at: "file.txt")
    /// > item.exits // true
    /// > item.generateOutputPath()
    /// > item // file 2.txt
    /// > ```
    @available(*, deprecated, renamed: "generateUniquePath()", message: "Use the non-mutating version instead.")
    func generateOutputPath() {
        self.url = generateUniquePath().url
    }
    
    /// Ensures file uniqueness by creating a non-duplicating file path.
    ///
    /// This function creates a distinct ``FinderItem`` for a given file path, verifying that no duplicate file paths are present on the disk. It effectively manages scenarios where a file already exists at the specified location.
    ///
    /// ```swift
    /// let item = FinderItem(at: "file.txt")
    /// item.exits // true
    /// item.createUniquePath() // file 2.txt
    /// ```
    ///
    /// If the name is in the format of `.*? ?(\d+)`, the number will be considered as index, and continue counting.
    ///
    /// ```swift
    /// let item = FinderItem(at: "music 324.m4a")
    /// item.exits // true
    /// item.createUniquePath() // music 325.m4a
    /// ```
    @inlinable
    func generateUniquePath() -> FinderItem {
        guard self.exists else { return self }
        
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
            
            return enclosingFolder.appending(path: "\(stem)\(counter).\(extensionName)")
        } else {
            while enclosingFolder.appending(path: "\(stem)\(counter)").exists {
                counter += 1
            }
            return enclosingFolder.appending(path: "\(stem)\(counter)")
        }
    }
    
    @available(*, deprecated, renamed: "generateUniquePath()")
    @inlinable
    func createUniquePath() -> FinderItem {
        self.generateUniquePath()
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
    /// - Note: The leading `/` is optional in `path`.
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
    /// The is a file path operation. A new instance of ``FinderItem`` is generated upon return.
    ///
    /// ```swift
    /// let item = FinderItem(at: "file.txt")
    /// item.replacingExtension(with: "png") // "file.png"
    /// ```
    ///
    /// - Note: `extension` can be empty, which indicates no extension.
    ///
    /// - Parameters:
    ///   - extensionName: The new extension.
    @inlinable
    func replacingExtension(with extensionName: some StringProtocol) -> FinderItem {
        let name = extensionName as? String ?? String(extensionName)
        return self.enclosingFolder.appending(path: name.isEmpty ? self.stem : self.stem + "." + name)
    }
    
    /// Returns a new instance with the path by replacing the stem with the new value.
    ///
    /// The is a file path operation. A new instance of ``FinderItem`` is generated upon return.
    ///
    /// ```swift
    /// let item = FinderItem(at: "file.txt")
    /// item.replacingStem(with: "text") // "text.txt"
    /// ```
    ///
    /// - Precondition: `stem` cannot be empty.
    ///
    /// - Parameters:
    ///   - stem: The new stem.
    @inlinable
    func replacingStem(with stem: some StringProtocol) -> FinderItem {
        precondition(!stem.isEmpty, "`stem` cannot be empty.")
        
        let name = stem as? String ?? String(stem)
        let ext = self.extension
        return self.enclosingFolder.appending(path: ext.isEmpty ? name : name + "." + ext)
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
    @available(*, deprecated, renamed: "replacingExtension(with:)")
    @inlinable
    func with(extension name: some StringProtocol) -> FinderItem {
        self.replacingExtension(with: name)
    }
    
    
    // MARK: - Type Methods
    
    /// Returns the item for the resource by the name in the app's ``bundleDirectory``.
    ///
    /// - Parameters:
    ///   - name: The name of the resource file.
    ///   - ext: The extension of the resource file.
    ///   - subdirectory: The directory inside the bundle.
    ///   - bundle: The bundle in which the file exists.
    ///
    /// - Returns: The ``FinderItem`` for the resource file or `nil` if the file could not be located.
    @inlinable
    static func bundleItem(forResource name: String?, withExtension ext: String?, subdirectory: String? = nil, in bundle: Bundle = .main) throws -> FinderItem {
        guard let url = bundle.url(forResource: name, withExtension: ext, subdirectory: subdirectory) else {
            var path = ""
            if let subdirectory {
                path += subdirectory + "/"
            }
            if let name {
                path += name
            }
            if let ext {
                path += "." + ext
            }
            
            throw FileError(code: .cannotRead(reason: .noSuchFile), source: .bundleDirectory/path)
        }
        return FinderItem(at: url)
    }
    
    /// Returns the normalized path from the given shell path.
    @inlinable
    static func normalize(shellPath: String, shouldRemoveTrailingSpace: Bool = true) -> String {
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
    
    /// Returns a new instance with the path of its child.
    ///
    /// ```swift
    /// let item = FinderItem(at: "folder/")
    /// item/"file.txt" // "folder/file"
    /// ```
    ///
    /// - Parameters:
    ///   - lhs: The enclosing folder.
    ///   - rhs: The relative path. A `/` should be added to the end as an indication of being a folder.
    ///
    /// - Returns: A new instance with the path of its child.
    @inlinable
    static func /(_ lhs: FinderItem, _ rhs: some StringProtocol) -> FinderItem {
        lhs.appending(path: rhs)
    }
}
