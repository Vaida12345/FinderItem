//
//  Attributes.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem {
    
    public struct Attributes: @unchecked Sendable {
        
        /// stores common properties.
        ///
        /// As these attributes are obtained together using `stat` under the hood, caching it is better.
        @usableFromInline
        let _fm_attributes: [FileAttributeKey : Any]
        
        @usableFromInline
        let parent: FinderItem
        
        
        @usableFromInline
        init(parent: FinderItem) throws {
            self.parent = parent
            self._fm_attributes = try FileManager.default.attributesOfItem(atPath: parent.path)
        }
        
    }
    
}


extension FinderItem {
    
    /// Returns the attributes collection of the given item.
    ///
    /// - Note: To improve performance and reduce file read, retain this value.
    @inlinable
    public var attributes: Attributes {
        get throws(FileError) {
            do {
                return try Attributes(parent: self)
            } catch {
                throw FileError.parse(error)
            }
        }
    }
    
}
