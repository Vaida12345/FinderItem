//
//  Attributes.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem {
    
    /// A cached snapshot of file metadata for a specific item.
    public final class Attributes: @unchecked Sendable {
        
        /// Stores common file attributes fetched through `FileManager`.
        ///
        /// As these attributes are obtained together using `stat` under the hood, caching it is better.
        @usableFromInline
        lazy var _fm_attributes: [FileAttributeKey : Any] = (try? FileManager.default.attributesOfItem(atPath: parent.path)) ?? [:]
        
        /// The item that owns these attributes.
        @usableFromInline
        let parent: FinderItem
        
        
        @usableFromInline
        init(parent: FinderItem) {
            self.parent = parent
        }
        
    }
    
}


extension FinderItem {
    
    /// Returns the attribute snapshot for this item.
    ///
    /// Taking the snapshot does not read the file. Attributes are read when they are accessed, and the ones that can fail throw a ``FileError``.
    ///
    /// - Tip: To improve performance and reduce file reads, retain this value.
    @inlinable
    public var attributes: Attributes {
        Attributes(parent: self)
    }
    
}
