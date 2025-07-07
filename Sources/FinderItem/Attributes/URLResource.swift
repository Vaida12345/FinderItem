//
//  URLResource.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-06.
//

import Foundation
import Accelerate


extension FinderItem {
    
    /// Returns a resource value identified by the given resource key.
    ///
    /// This function returns `nil` when the retrieval process if completed without error, but there isn't a value associated with the given key.
    ///
    /// You can also define your own keys that can be inserted using this method, see ``ResourceKey``.
    ///
    /// - Returns: `nil` if there’s no available value for the given key.
    ///
    /// - Throws: If this method fails to determine a value’s availability or retrieve its value.
    @inlinable
    public func load<T>(_ resource: ResourceKey<T>) throws -> sending T? {
        try resource.load(self)
    }
    
    /// A generic attribute resource key.
    ///
    /// You can create extensions to this structure to define your own keys, for example:
    /// ```swift
    /// extension FinderItem.InsertableAttributeKey {
    ///    static var isApplication: FinderItem.ResourceKey<Bool> {
    ///         .init { source in
    ///             try source.url.resourceValues(forKeys: [.isApplicationKey]).isApplication
    ///         }
    ///     }
    /// }
    /// ```
    public struct ResourceKey<T>: Sendable {
        
        @usableFromInline
        let load: @Sendable (_ source: FinderItem) throws -> T?
        
        /// A new resource key with the given closure.
        ///
        /// This closure should return `nil` only when the retrieval process if completed without error, but there isn't a value associated with the given key.
        ///
        /// - Parameters:
        ///   - load: The closure that gets called to load an attribute from `$0`.
        @inlinable
        public init(load: @Sendable @escaping (_: FinderItem) throws -> T?) {
            self.load = load
        }
    }
    
}


public extension FinderItem.ResourceKey {
    
    /// Returns whether the resource is an application.
    @inlinable
    static var isApplication: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isApplicationKey]).isApplication
        }
    }
    
    /// Returns `true` if the resource is a Finder alias file or a symlink, `false` otherwise
    ///
    /// - note: Only applicable to regular files.
    @inlinable
    static var isAlias: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile
        }
    }
    
    /// Returns whether the resource is a file package.
    @inlinable
    static var isPackage: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isPackageKey]).isPackage
        }
    }
    
    /// A Boolean value that indicates whether you can execute the file resource or search a directory resource.
    @inlinable
    static var isExecutable: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isExecutableKey]).isExecutable
        }
    }
    
    /// Returns `true` for resources normally not displayed to users.
    @inlinable
    static var isHidden: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isHiddenKey]).isHidden
        }
    }
    
    /// Returns whether the resource is a symbolic link
    @inlinable
    static var isSymbolicLink: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink
        }
    }
    
    /// Determines whether the file is writable.
    @inlinable
    static var isWritable: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isWritableKey]).isWritable
        }
    }
    
    /// Determines whether the file is readable.
    @inlinable
    static var isReadable: FinderItem.ResourceKey<Bool> {
        .init { source in
            try source.url.resourceValues(forKeys: [.isReadableKey]).isReadable
        }
    }
    
    /// The total file size, in bytes.
    ///
    /// - note: Only applicable to regular files.
    @inlinable
    static var fileSize: FinderItem.ResourceKey<Int> {
        .init { source in
            try source.url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        }
    }
    
    /// The type of the file system object.
    @inlinable
    static var resourceType: FinderItem.ResourceKey<URLFileResourceType> {
        .init { source in
            try source.url.resourceValues(forKeys: [.fileResourceTypeKey]).fileResourceType
        }
    }
    
    /// The date the resource was last accessed.
    @inlinable
    static var dateAccessed: FinderItem.ResourceKey<Date> {
        .init { source in
            try source.url.resourceValues(forKeys: [.contentAccessDateKey]).contentAccessDate
        }
    }
    
    /// The time at which the resource was created.
    ///
    /// - Important: This API has the potential of being misused to access device signals to try to identify the device or user, also known as fingerprinting. Regardless of whether a user gives your app permission to track, fingerprinting is not allowed. When you use this API in your app or third-party SDK (an SDK not provided by Apple), declare your usage and the reason for using the API in your app or third-party SDK’s `PrivacyInfo.xcprivacy` file. For more information, including the list of valid reasons for using the API, see [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
    @inlinable
    static var dateCreated: FinderItem.ResourceKey<Date> {
        .init { source in
            try source.url.resourceValues(forKeys: [.creationDateKey]).creationDate
        }
    }
    
    /// The time the resource content was last modified.
    ///
    /// - Important: This API has the potential of being misused to access device signals to try to identify the device or user, also known as fingerprinting. Regardless of whether a user gives your app permission to track, fingerprinting is not allowed. When you use this API in your app or third-party SDK (an SDK not provided by Apple), declare your usage and the reason for using the API in your app or third-party SDK’s `PrivacyInfo.xcprivacy` file. For more information, including the list of valid reasons for using the API, see [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
    @inlinable
    static var dateModified: FinderItem.ResourceKey<Date> {
        .init { source in
            try source.url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        }
    }
    
}


#if os(macOS)
import AppKit

public extension FinderItem.ResourceKey {
    
    /// The icon stored with the resource
    @inlinable
    static var customIcon: FinderItem.ResourceKey<NSImage> {
        .init { source in
            try source.url.resourceValues(forKeys: [.customIconKey]).customIcon
        }
    }
    
    /// The resource’s normal icon
    @inlinable
    static var effectiveIcon: FinderItem.ResourceKey<NSImage> {
        .init { source in
            try source.url.resourceValues(forKeys: [.effectiveIconKey]).effectiveIcon as? NSImage
        }
    }
    
}
#endif
