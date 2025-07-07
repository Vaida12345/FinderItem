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
    /// If this method returns true, then you must relinquish access as soon as you finish using the resource. Call the ``stopAccessingSecurityScopedResource()`` method to relinquish access. You must balance each call to a given resource. When you make the last balanced call, you immediately lose access to the resource.
    ///
    /// - SeeAlso: ``withAccessingSecurityScopedResource(perform:)``
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
    /// - SeeAlso: ``withAccessingSecurityScopedResource(perform:)``
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
    ///   - action: The action which is performed. The `source` of the closure is exactly the same as the `source` passed, the value is provided to prevent capture.
    @inlinable
    public func withAccessingSecurityScopedResource<Result>(perform action: (_ source: FinderItem) throws -> Result) throws -> Result {
        try self.startAccessingSecurityScopedResource()
        defer { self.stopAccessingSecurityScopedResource() }
        
        return try action(self)
    }

    
    // MARK: - Bookmark
    
    /// Returns bookmark data for the URL, created with specified options.
    ///
    /// - Note: You only need to uses this method when you choose to handle bookmarks manually, otherwise encode and decode with `withSecurityScope` configuration is sufficient.
    @inlinable
    public func bookmarkData(options: URL.BookmarkCreationOptions = FinderItem.defaultBookmarkCreationOptions) throws -> Data {
        try self.url.bookmarkData(options: options)
    }
    
    /// Creates a URL that refers to a location specified by resolving bookmark data.
    ///
    /// - Note: You only need to uses this method when you choose to handle bookmarks manually, otherwise encode and decode with `withSecurityScope` configuration is sufficient.
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
}


extension Sequence<FinderItem> {
    /// In an app that has adopted App Sandbox, makes the resource pointed to by a security-scoped URL available to the app.
    ///
    /// If this method returns true, then you must relinquish access as soon as you finish using the resource. Call the ``stopAccessingSecurityScopedResource()`` method to relinquish access. You must balance each call to a given resource. When you make the last balanced call, you immediately lose access to the resource.
    ///
    /// - SeeAlso: ``FinderItem/withAccessingSecurityScopedResource(perform:)``
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
    /// - SeeAlso: ``FinderItem/withAccessingSecurityScopedResource(perform:)``
    @inlinable
    public func stopAccessingSecurityScopedResource() {
        for i in self {
            i.stopAccessingSecurityScopedResource()
        }
    }
}
