//
//  FinderItem + SecureScope.swift
//  The FinderItem Module
//
//  Created by Vaida on 6/3/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#endif
import Essentials


extension FinderItem {
    
    // MARK: - Secure Scope
    
    /// In an app that has adopted App Sandbox, makes the resource pointed to by a security-scoped URL available to the app.
    ///
    /// If this method returns true, then you must relinquish access as soon as you finish using the resource. Call the ``stopAccessSecurityScope()`` method to relinquish access. You must balance each call to a given resource. When you make the last balanced call, you immediately lose access to the resource.
    ///
    /// - SeeAlso: ``withAccessingSecurityScopedResource(to:perform:)``
    ///
    /// - throws: ``FinderItem/FileError/Code-swift.enum/cannotRead(reason:)``, with reason ``FinderItem/FileError/Code-swift.enum/ReadFailureReason/noPermission``.
    ///
    /// You need to obtain security scope for items that are created using ``FinderItem/init(from:configuration:)``.
    @inlinable
    public func startAccessingSecurityScopedResource() throws(FileError) {
        guard self.url.startAccessingSecurityScopedResource() else { throw FinderItem.FileError(code: .cannotRead(reason: .noPermission), source: self) }
    }
    
    /// In an app that adopts App Sandbox, revokes access to the resource pointed to by a security-scoped URL.
    ///
    /// - SeeAlso: ``withAccessingSecurityScopedResource(to:perform:)``
    @inlinable
    public func stopAccessingSecurityScopedResource() {
        self.url.stopAccessingSecurityScopedResource()
    }
    
    /// Access and performs `action` on the resource that is outside the sandbox of the App.
    ///
    /// Given a `FinderItem` created by resolving a bookmark data created with security scope, make the resource referenced by the `item` accessible to the process.
    ///
    /// - throws: *Cannot access Security Scoped Resource* error if access denied, or whatever is thrown by the `action`.
    ///
    /// - Returns: Whatever is returned by the `action`.
    ///
    /// - Parameters:
    ///   - source: The `FinderItem` which refers to an item outside the sandbox of the app.
    ///   - action: The action which is performed. The `source` of the closure is exactly the same as the `source` passed, the value is provided to prevent capture.
    @inlinable
    public func withAccessingSecurityScopedResource<Result>(perform action: (_ source: FinderItem) throws -> Result) throws -> Result {
        try self.startAccessingSecurityScopedResource()
        defer { self.stopAccessingSecurityScopedResource() }
        
        return try action(self)
    }

    
    // MARK: - Bookmark
    
    /// Returns bookmark data for the URL, created with specified options.
    @inlinable
    public func bookmarkData(options: URL.BookmarkCreationOptions = FinderItem.defaultBookmarkCreationOptions) throws -> Data {
        try self.url.bookmarkData(options: options)
    }
    
    /// Creates a URL that refers to a location specified by resolving bookmark data.
    ///
    /// - Parameters:
    ///   - resolvingBookmarkData: The bookmark data
    ///   - options: The options for resolving such data, `.withSecurityScope` for default.
    ///   - bookmarkDataIsStale: On return, if true, the bookmark data is stale. Your app should create a new bookmark using the returned URL and use it in place of any stored copies of the existing bookmark.
    @inlinable
    public convenience init(resolvingBookmarkData: Data, options: URL.BookmarkResolutionOptions = FinderItem.defaultBookmarkResolveOptions, bookmarkDataIsStale: inout Bool) throws {
        var bookmarkDataIsStale = false
        let url = try URL(resolvingBookmarkData: resolvingBookmarkData, options: options, bookmarkDataIsStale: &bookmarkDataIsStale)
        self.init(_url: url)
    }
    
    /// The default option for bookmark resolve.
    ///
    /// On macOS, it is `withSecurityScope`; `[]` otherwise.
    @inlinable
    public static var defaultBookmarkResolveOptions: URL.BookmarkResolutionOptions {
#if os(macOS)
        .withSecurityScope
#else
        []
#endif
    }
    
    /// The default option for bookmark creation.
    ///
    /// On macOS, it is `withSecurityScope`; `[]` otherwise.
    @inlinable
    public static var defaultBookmarkCreationOptions: URL.BookmarkCreationOptions {
#if os(macOS)
        .withSecurityScope
#else
        []
#endif
    }
    
    
#if os(macOS)
    
    /// Prompt the user to provide access to the given file.
    ///
    /// After the permission was given, this method would replace the underlying url, and store the bookmark in `UserDefaults`.
    ///
    /// If the user had already provided access, this function would change the underlying url, and the access *would not* require ``tryAccessSecurityScope()``.
    ///
    /// - Important: This method should be used on folders.
    ///
    /// ### Method Call
    ///
    /// You can ask the user for permission, or retrieve the permission by calling
    /// ```swift
    /// let item = FinderItem.downloadsDirectory
    /// try await item.tryPromptAccessFile()
    /// ```
    /// If the user did not provide such permission, a `NSOpenPanel` will be displayed, asking the user for permissions.
    ///
    /// If the user did, this method would return without displaying any user interface.
    ///
    /// ### Return
    ///
    /// After successful return, you could access the contents of `self` without permission errors.
    ///
    /// You need to call ``stopAccessSecurityScope()`` on finish with the files.
    ///
    /// ## Topics
    /// ### Error Type
    /// - ``AccessFilePromptError``
    @MainActor
    public func tryPromptAccessFile() async throws {
        if let data = UserDefaults.standard.data(forKey: self.path) {
            var bookmarkDataIsStale = false
            let url = try URL(resolvingBookmarkData: data, options: .withSecurityScope, bookmarkDataIsStale: &bookmarkDataIsStale)
            self.url = url
            if bookmarkDataIsStale {
                UserDefaults.standard.set(try url.bookmarkData(options: .withSecurityScope), forKey: self.path)
            }
            try self.startAccessingSecurityScopedResource()
            return
        }
        
        let openPanel = NSOpenPanel()
        openPanel.directoryURL = self.url
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.prompt = "Allow"
        openPanel.message = "The app would like to access this folder."
        
        let response = await openPanel.begin()
        
        switch response {
        case .OK:
            let url = openPanel.url!
            UserDefaults.standard.set(try url.bookmarkData(options: .withSecurityScope), forKey: self.path)
            self.url = url
        default:
            throw AccessFilePromptError.moduleResponse(response)
        }
    }
    
    public enum AccessFilePromptError: GenericError {
        case moduleResponse(NSApplication.ModalResponse)
        
        @inlinable
        public var title: String {
            "File Access Error"
        }
        
        @inlinable
        public var message: String {
            switch self {
            case .moduleResponse(let response):
                "The user denied access. (Response: \(response))"
            }
        }
    }
#endif
    
}


extension Sequence<FinderItem> {
    /// In an app that has adopted App Sandbox, makes the resource pointed to by a security-scoped URL available to the app.
    ///
    /// If this method returns true, then you must relinquish access as soon as you finish using the resource. Call the ``stopAccessSecurityScope()`` method to relinquish access. You must balance each call to a given resource. When you make the last balanced call, you immediately lose access to the resource.
    ///
    /// - SeeAlso: ``withAccessingSecurityScopedResource(to:perform:)``
    ///
    /// - throws: ``FinderItem/FileError/Code-swift.enum/cannotRead(reason:)``, with reason ``FinderItem/FileError/Code-swift.enum/ReadFailureReason/noPermission``.
    ///
    /// You need to obtain security scope for items that are created using ``FinderItem/init(from:configuration:)``.
    @inlinable
    public func startAccessingSecurityScopedResource() throws(FinderItem.FileError) {
        for i in self {
            try i.startAccessingSecurityScopedResource()
        }
    }
    
    /// In an app that adopts App Sandbox, revokes access to the resource pointed to by a security-scoped URL.
    ///
    /// - SeeAlso: ``withAccessingSecurityScopedResource(to:perform:)``
    @inlinable
    public func stopAccessingSecurityScopedResource() {
        for i in self {
            i.stopAccessingSecurityScopedResource()
        }
    }
}
