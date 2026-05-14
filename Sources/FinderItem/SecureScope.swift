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
    /// Call ``stopAccessingSecurityScopedResource()`` as soon as you finish using the resource.
    /// Access calls must be balanced per resource.
    ///
    /// - SeeAlso: ``withAccessingSecurityScopedResource(perform:)``
    ///
    /// - Throws: ``FinderItem/FileError/Code-swift.enum/cannotRead(reason:)`` with reason ``FinderItem/FileError/Code-swift.enum/ReadFailureReason/noPermission`` when access cannot be started.
    ///
    /// This is typically needed for items restored from security-scoped bookmarks.
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
    
    /// Starts security-scope access, runs `action`, then always relinquishes access.
    ///
    /// Given a `FinderItem` created by resolving security-scoped bookmark data,
    /// this makes the resource accessible for the duration of `action`.
    ///
    /// - Throws: A permission-related ``FinderItem/FileError`` if access cannot start, or any error thrown by `action`.
    ///
    /// - Parameters:
    ///   - action: The operation to perform while security-scope access is active.
    ///
    /// - Returns: The value returned by `action`.
    @inlinable
    public func withAccessingSecurityScopedResource<Result>(perform action: (_ source: FinderItem) throws -> Result) throws -> Result {
        try self.startAccessingSecurityScopedResource()
        defer { self.stopAccessingSecurityScopedResource() }
        
        return try action(self)
    }

    
    // MARK: - Bookmark
    
    /// Returns bookmark data for the URL, created with specified options.
    ///
    /// - Note: You only need this method when handling bookmarks manually. Otherwise, encoding and decoding with `withSecurityScope` is sufficient.
    @inlinable
    public func bookmarkData(options: URL.BookmarkCreationOptions = FinderItem.defaultBookmarkCreationOptions) throws -> Data {
        try self.url.bookmarkData(options: options)
    }
    
    /// Creates a URL that refers to a location specified by resolving bookmark data.
    ///
    /// - Note: You only need this method when handling bookmarks manually. Otherwise, encoding and decoding with `withSecurityScope` is sufficient.
    ///
    /// - Parameters:
    ///   - resolvingBookmarkData: The bookmark data.
    ///   - options: The options for resolving such data, `.withSecurityScope` for default.
    ///   - bookmarkDataIsStale: On return, if true, the bookmark data is stale. Your app should create a new bookmark using the returned URL and use it in place of any stored copies of the existing bookmark.
    @inlinable
    public convenience init(resolvingBookmarkData: Data, options: URL.BookmarkResolutionOptions = FinderItem.defaultBookmarkResolveOptions, bookmarkDataIsStale: inout Bool) throws {
        let url = try URL(resolvingBookmarkData: resolvingBookmarkData, options: options, bookmarkDataIsStale: &bookmarkDataIsStale)
        self.init(_url: url)
    }
    
    /// The default options for bookmark resolution.
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
    
    /// The default options for bookmark creation.
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
    /// Starts security-scope access for every item in the sequence.
    ///
    /// - SeeAlso: ``FinderItem/withAccessingSecurityScopedResource(perform:)``
    ///
    /// - Throws: ``FinderItem/FileError/Code-swift.enum/cannotRead(reason:)`` with reason ``FinderItem/FileError/Code-swift.enum/ReadFailureReason/noPermission`` when any item fails.
    ///
    /// This is typically needed for items restored from security-scoped bookmarks.
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
