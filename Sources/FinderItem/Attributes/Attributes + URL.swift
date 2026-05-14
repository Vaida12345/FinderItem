//
//  Attributes + URL.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem.Attributes {
    
    @inlinable
    func _read<T>(_URLResourceKey: URLResourceKey, keyPath: KeyPath<URLResourceValues, T>) throws(FinderItem.FileError) -> T {
        do {
            return try self.parent.url.resourceValues(forKeys: [_URLResourceKey])[keyPath: keyPath]
        } catch {
            throw .parse(error)
        }
    }

    /// Returns whether the resource is an application.
    @inlinable
    public var isApplication: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isApplicationKey, keyPath: \.isApplication)
        }
    }
    
    /// Returns whether the resource is a Finder alias file.
    ///
    /// - Note: Only applicable to regular files.
    @inlinable
    public var isAliasFile: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isAliasFileKey, keyPath: \.isAliasFile)
        }
    }
    
    /// Returns whether the resource is a file package.
    @inlinable
    public var isPackage: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isPackageKey, keyPath: \.isPackage)
        }
    }
    
    /// A Boolean value that indicates whether you can execute the file resource or search a directory resource.
    @inlinable
    public var isExecutable: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isExecutableKey, keyPath: \.isExecutable)
        }
    }
    
    /// Returns `true` for resources normally not displayed to users.
    @inlinable
    public var isHidden: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isHiddenKey, keyPath: \.isHidden)
        }
    }
    
    /// Returns whether the resource is a symbolic link.
    @inlinable
    public var isSymbolicLink: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isSymbolicLinkKey, keyPath: \.isSymbolicLink)
        }
    }
    
    /// Determines whether the file is writable.
    @inlinable
    public var writable: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isWritableKey, keyPath: \.isWritable)
        }
    }
    
    /// Determines whether the file is readable.
    @inlinable
    public var readable: Bool? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .isReadableKey, keyPath: \.isReadable)
        }
    }
    
    /// The date the resource was last accessed.
    @inlinable
    public var accessDate: Date? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .contentAccessDateKey, keyPath: \.contentAccessDate)
        }
    }
    
    /// The user-visible label text.
    @inlinable
    public var label: String? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .localizedLabelKey, keyPath: \.localizedLabel)
        }
    }
    
    /// User-visible type or “kind” description.
    @inlinable
    public var displayType: String? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .localizedTypeDescriptionKey, keyPath: \.localizedTypeDescription)
        }
    }
    
    #if os(macOS)
    /// The quarantine properties as defined in `LSQuarantine.h`.
    @inlinable
    public var quarantine: [String : Any]? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .quarantinePropertiesKey, keyPath: \.quarantineProperties)
        }
    }
    #endif
}


#if os(macOS) && canImport(AppKit)
import AppKit

extension FinderItem.Attributes {
    
    /// The icon stored with the resource.
    @inlinable
    public var customIcon: NSImage? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .customIconKey, keyPath: \.customIcon)
        }
    }
    
    /// The resource’s normal icon.
    @inlinable
    public var effectiveIcon: NSImage? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .effectiveIconKey, keyPath: \.effectiveIcon) as? NSImage
        }
    }
    
    /// The resource’s label color.
    @inlinable
    public var labelColor: NSColor? {
        get throws(FinderItem.FileError) {
            try _read(_URLResourceKey: .labelColorKey, keyPath: \.labelColor)
        }
    }
    
}

#endif
