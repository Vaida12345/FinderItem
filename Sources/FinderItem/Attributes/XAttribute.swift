//
//  ExtendedResources.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-06.
//

#if canImport(Darwin)
import Darwin
import Foundation
import DetailedDescription
import Essentials
import System


extension FinderItem {
    
    /// Loads an extended attribute.
    ///
    /// To obtain a list of attributes associated with `file`,
    /// ```swift
    /// try file.load(.xattr)
    /// ```
    ///
    /// To obtain the value of a specific key
    /// ```swift
    /// try item.load(.xattr("com.apple.metadata:kMDItemKeywords"))
    /// ```
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    ///
    /// - SeeAlso: The package comes with a set of common attributes, see ``CommonXAttributeKey``.
    ///
    /// - returns: Refer to documentation of the `attributeKey`. `nil` is only returned when it cannot be parsed.
    @inlinable
    public func load<T>(_ attributeKey: XAttributeKey<T>) throws(Errno) -> T {
        try attributeKey.load(self)
    }
    
    /// Load an extended attribute using its name.
    ///
    /// Please refer to the type properties for predefined keys.
    ///
    /// ## Topics
    /// ### Obtains all keys
    /// Returns all keys associated with a file
    /// - ``xattr``
    ///
    /// ### Obtains value of a key
    /// Returns value associated with the given key name
    /// - ``xattr(_:)``
    /// - ``xattr(_:as:)``
    public struct XAttributeKey<Value> {
        
        @usableFromInline
        let load: (_ source: FinderItem) throws(Errno) -> Value
        
        
        @inlinable
        init(load: @escaping (_: FinderItem) throws(Errno) -> Value) {
            self.load = load
        }
        
    }
}


extension FinderItem.XAttributeKey {
    
    /// Returns all of extended attribute keys associated with `self`.
    ///
    /// - throws: Error in retrieval process.
    ///
    /// - Returns: `[]` when there aren't any attributes associated with `self`.
    @inlinable
    public static var xattr: FinderItem.XAttributeKey<[String]> {
        .init { source throws(Errno) in
            let bufferSize = listxattr(source.path, nil, 0, 0)
            if bufferSize == 0 {
                return []
            } else if bufferSize == -1 {
                throw Errno(rawValue: errno)
            }
            
            let namebuf = [CChar](unsafeUninitializedCapacity: bufferSize) { buffer, initializedCount in
                listxattr(source.path, buffer.baseAddress, bufferSize, 0)
                initializedCount = bufferSize
            }
            
            return namebuf.split(separator: 0).compactMap {
                return String(decoding: $0.map(UInt8.init), as: UTF8.self)
            }
        }
    }
}

extension FinderItem.XAttributeKey {
    
    /// Returns the extended attribute associated with the given `name` as unparsed raw data.
    ///
    /// This method returns the value associated with `name` as an array of `UInt8`.
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    ///
    /// - throws: Error in retrieval process.
    ///
    /// - SeeAlso: The package comes with a set of common attributes, see ``CommonXAttributeKey``.
    ///
    /// - SeeAlso: Use ``xattr(_:as:)`` to parse as `String?` or property list (`Any?`).
    @inlinable
    public static func xattr(_ name: String) -> FinderItem.XAttributeKey<[UInt8]> {
        .init { item throws(Errno) in
            let size = getxattr(item.path, name, nil, 0, 0, 0)
            if size == -1 {
                throw Errno(rawValue: errno)
            }
            
            return [UInt8](unsafeUninitializedCapacity: size) { buffer, initializedCount in
                getxattr(item.path, name, buffer.baseAddress, size, 0, 0)
                initializedCount = size
            }
        }
    }
    
    /// Returns the extended attribute associated with the given `name` as a `String`, or `nil` if the data is not a `String`.
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    ///
    /// - throws: Error in retrieval process.
    ///
    /// - SeeAlso: The package comes with a set of common attributes, see ``CommonXAttributeKey``.
    ///
    /// - SeeAlso: Use ``xattr(_:)`` to read the value as it is.
    ///
    /// - returns: `nil` only when data is not a `String`.
    @inlinable
    public static func xattr(_ name: String, as type: Value.Type = Value.self) -> FinderItem.XAttributeKey<String?> {
        FinderItem.XAttributeKey { item throws(Errno) in
            let raw = try item.load(.xattr(name)) as [UInt8]
            return String(bytes: raw, encoding: .utf8)
        }
    }
    
    /// Returns the extended attribute associated with the given `name` as a property list, or `nil` if the data is not a property list.
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    ///
    /// - throws: Error in retrieval process.
    ///
    /// - SeeAlso: The package comes with a set of common attributes, see ``CommonXAttributeKey``.
    ///
    /// - SeeAlso: Use ``xattr(_:)`` to read the value as it is.
    ///
    /// - returns: `nil` only when data is not a property list.
    @inlinable
    public static func xattr(_ name: String, as type: Value.Type = Value.self) -> FinderItem.XAttributeKey<Any?> {
        FinderItem.XAttributeKey { item throws(Errno) in
            let raw = try item.load(.xattr(name)) as [UInt8]
            return raw.withUnsafeBytes { bytes in
                let data = Data(bytesNoCopy: .init(mutating: bytes.baseAddress!), count: raw.count, deallocator: .none)
                return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            }
        }
    }
}
#endif
