//
//  Attributes + kMDItem.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-25.
//

import CoreServices


extension FinderItem.Attributes {
    
    /// Returns whether the file has a custom icon.
    ///
    /// - Returns: `false` if the attribute is not found.
    @inlinable
    public var hasCustomIcon: Bool {
        get throws(FinderItem.FileError) {
            guard let metadata = MDItemCreate(nil, parent.path as CFString) else { throw FinderItem.FileError(code: .cannotRead(reason: .unknown), source: self.parent) }
            guard let flags = MDItemCopyAttribute(metadata, "kMDItemFSFinderFlags" as CFString) as? UInt16 else { return false }
            return flags & 0x0400 != 0
        }
    }
    
}
