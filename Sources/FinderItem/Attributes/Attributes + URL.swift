//
//  Attributes + URL.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem.Attributes {
    
    /// Returns whether the resource is an application.
    @inlinable
    var isApplication: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isApplicationKey]).isApplication
        }
    }
    
    /// Returns `true` if the resource is a Finder alias file or a symlink, `false` otherwise
    ///
    /// - note: Only applicable to regular files.
    @inlinable
    var isAliasFile: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isAliasFileKey]).isAliasFile
        }
    }
    
    /// Returns whether the resource is a file package.
    @inlinable
    var isPackage: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isPackageKey]).isPackage
        }
    }
    
    /// A Boolean value that indicates whether you can execute the file resource or search a directory resource.
    @inlinable
    var isExecutable: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isExecutableKey]).isExecutable
        }
    }
    
    /// Returns `true` for resources normally not displayed to users.
    @inlinable
    var isHidden: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isHiddenKey]).isHidden
        }
    }
    
    /// Returns whether the resource is a symbolic link
    @inlinable
    var isSymbolicLink: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink
        }
    }
    
    /// Determines whether the file is writable.
    @inlinable
    var writable: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isWritableKey]).isWritable
        }
    }
    
    /// Determines whether the file is readable.
    @inlinable
    var readable: Bool? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.isReadableKey]).isReadable
        }
    }
    
    /// The date the resource was last accessed.
    @inlinable
    var accessDate: Date? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.contentAccessDateKey]).contentAccessDate
        }
    }
    
    /// The user-visible label text.
    @inlinable
    var label: String? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.localizedLabelKey]).localizedLabel
        }
    }
    
    /// User-visible type or “kind” description.
    @inlinable
    var displayType: String? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.localizedTypeDescriptionKey]).localizedTypeDescription
        }
    }
    
    /// The quarantine properties as defined in `LSQuarantine.h`.
    @inlinable
    var quarantine: [String : Any]? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.quarantinePropertiesKey]).quarantineProperties
        }
    }
    
}


#if os(macOS) && canImport(AppKit)
import AppKit

extension FinderItem.Attributes {
    
    /// The icon stored with the resource
    @inlinable
    var customIcon: NSImage? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.customIconKey]).customIcon
        }
    }
    
    /// The resource’s normal icon
    @inlinable
    var effectiveIcon: NSImage? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.effectiveIconKey]).effectiveIcon as? NSImage
        }
    }
    
    /// The resource’s label color
    @inlinable
    var labelColor: NSColor? {
        get throws {
            try self.parent.url.resourceValues(forKeys: [.labelColorKey]).labelColor
        }
    }
    
}

#endif
