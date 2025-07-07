//
//  insert.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-07.
//

import Essentials
import Foundation


extension FinderItem {
    
    /// Inserts and replaces existing attributes.
    ///
    /// You can also define your own keys that can be inserted using this method, see ``InsertableAttributeKey``.
    @inlinable
    public func insertAttribute<T, E: Error>(_ attribute: InsertableAttributeKey<T, E>, _ value: T) throws (E) {
        try attribute.insertTo(self, value)
    }
    
    /// Inserts and replaces an existing `Boolean` attribute.
    ///
    /// By default, the attribute is inserted as `true`. You can override this using ``insertAttribute(_:_:)``, or
    /// ```swift
    /// try file.insertAttribute(!.isPackage)
    /// ```
    ///
    /// You can also define your own keys that can be inserted using this method, see ``InsertableAttributeKey``.
    @inlinable
    public func insertAttribute<E: Error>(_ attribute: InsertableAttributeKey<Bool, E>) throws (E) {
        try attribute.insertTo(self, true)
    }
    
    
    /// A key indicating that the associated value can be inserted to a `FinderItem`.
    ///
    /// You can create extensions to this structure to define your own keys, for example:
    /// ```swift
    /// extension FinderItem.InsertableAttributeKey {
    ///    public static var isPackage: FinderItem.InsertableAttributeKey<Bool, any Error> {
    ///        .init { item, value in
    ///            var resourceValues = URLResourceValues()
    ///            resourceValues.isPackage = value
    ///            try item.url.setResourceValues(resourceValues)
    ///        }
    ///     }
    /// }
    /// ```
    public struct InsertableAttributeKey<Value, E> {
        
        @usableFromInline
        let insertTo: (_ item: FinderItem, _ value: Value) throws(E) -> Void
        
        /// Creates a new key.
        ///
        /// - Parameters:
        ///   - insertTo: A closure that is invoked to insert `value` to `item`.
        @inlinable
        public init(insertTo: @escaping (_ item: FinderItem, _ value: Value) throws(E) -> Void) {
            self.insertTo = insertTo
        }
    }
}

// MARK: - xattr
#if canImport(Darwin)

extension FinderItem.InsertableAttributeKey {
    
    /// Inserts an extended attribute with the given `name`.
    @inlinable
    public static func xattr(_ name: String) -> FinderItem.InsertableAttributeKey<Data, FinderItem.XAttributeError> {
        .init { item, value throws(FinderItem.XAttributeError) in
            let code = value.withUnsafeBytes { bytes in
                setxattr(item.path, name, bytes.baseAddress, value.count, 0, 0)
            }
            guard code == 0 else {
                throw .code(errno)
            }
        }
    }
    
}
#endif


// MARK: - URLResource
extension FinderItem.InsertableAttributeKey where Value == Bool, E == any Error {
    
    /// Negates the attribute.
    ///
    /// By default, booleans are inserted as `true`, use this function to insert `false`.
    /// ```swift
    /// try file.insertAttribute(.isPackage)  // inserts true
    /// try file.insertAttribute(!.isPackage) // inserts false
    /// ```
    @inlinable
    public static prefix func !(_ key: FinderItem.InsertableAttributeKey<Bool, any Error>) -> FinderItem.InsertableAttributeKey<Bool, any Error> {
        .init { item, value in
            try key.insertTo(item, !value)
        }
    }
    
}

extension FinderItem.InsertableAttributeKey {
    
    /// `true` for packaged directories.
    ///
    /// You can only set or clear this property on directories; if you try to set this property on non-directory objects, the property is ignored. If the directory is a package for some other reason (extension type, etc), setting this property to false will have no effect.
    public static var isPackage: FinderItem.InsertableAttributeKey<Bool, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.isPackage = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
    /// `true` for resources normally not displayed to users.
    ///
    /// If the resource is hidden because its name begins with a period, setting this value has no effect.
    public static var isHidden: FinderItem.InsertableAttributeKey<Bool, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.isHidden = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
    /// The time at which the resource was most recently accessed.
    public static var dateAccessed: FinderItem.InsertableAttributeKey<Date, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.contentAccessDate = value
            resourceValues.contentModificationDate = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
    /// The date the resource was created.
    ///
    /// A resource’s `dateCreated` value should be less than or equal to the resource’s `dateModified` and `dateAccessed`. Otherwise, the file system may change the `dateCreated` to the lesser of those values.
    public static var dateCreated: FinderItem.InsertableAttributeKey<Date, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.creationDate = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
    /// The time the resource content was last modified.
    public static var dateModified: FinderItem.InsertableAttributeKey<Date, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.contentModificationDate = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
}
