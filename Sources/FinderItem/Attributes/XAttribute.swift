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


extension FinderItem {
    
    /// Loads an extended attribute.
    ///
    /// - throws ``XAttributeError``
    ///
    /// - Tip: You can `detailedPrint` `self` with the ``DescriptionConfiguration/showExtendedAttributes`` option to view all attributes.
    @inlinable
    public func load<T>(_ attributeKey: XAttributeKey<T>) throws(FinderItem.XAttributeError) -> T {
        try attributeKey.load(self)
    }
    
    public struct XAttributeKey<Value> {
        
        @usableFromInline
        let load: (_ source: FinderItem) throws(FinderItem.XAttributeError) -> Value
        
        
        public init(load: @escaping (_: FinderItem) throws(FinderItem.XAttributeError) -> Value) {
            self.load = load
        }
        
    }
}


extension FinderItem.XAttributeKey {
    
    /// Returns the extended attribute keys associated with `self`.
    ///
    /// - Returns: `[]` when there aren't any attributes associated with `self`.
    @inlinable
    public static var xattr: FinderItem.XAttributeKey< [String]> {
        .init { source throws (FinderItem.XAttributeError) in
            let bufferSize = listxattr(source.path, nil, 0, 0)
            if bufferSize == 0 {
                return []
            } else if bufferSize == -1 {
                throw FinderItem.XAttributeError(code: errno)
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
    /// This method returns the value associated with `name` as an array of `UInt8`, use the overloads to parse as `String?` or property list (`Any?`).
    ///
    /// - Note: You do not use this function directly, you pass it to ``FinderItem/load(_:)``
    @inlinable
    public static func xattr(_ name: String) -> FinderItem.XAttributeKey<[UInt8]> {
        .init { item throws (FinderItem.XAttributeError) in
            let size = getxattr(item.path, name, nil, 0, 0, 0)
            if size == -1 {
                throw FinderItem.XAttributeError(code: errno)
            }
            
            return [UInt8](unsafeUninitializedCapacity: size) { buffer, initializedCount in
                getxattr(item.path, name, buffer.baseAddress, size, 0, 0)
                initializedCount = size
            }
        }
    }
    
    /// Returns the extended attribute associated with the given `name` as a `String`, or `nil` if the data is not a `String`.
    ///
    /// - Note: You do not use this function directly, you pass it to ``FinderItem/load(_:)``
    @inlinable
    public static func xattr(_ name: String, as type: Value.Type = Value.self) -> FinderItem.XAttributeKey<String?> {
        FinderItem.XAttributeKey { item throws(FinderItem.XAttributeError) in
            let raw = try item.load(.xattr(name)) as [UInt8]
            return String(bytes: raw, encoding: .utf8)
        }
    }
    
    /// Returns the extended attribute associated with the given `name` as a property list, or `nil` if the data is not a property list.
    ///
    /// - Note: You do not use this function directly, you pass it to ``FinderItem/load(_:)``
    @inlinable
    public static func xattr(_ name: String, as type: Value.Type = Value.self) -> FinderItem.XAttributeKey<Any?> {
        FinderItem.XAttributeKey { item throws(FinderItem.XAttributeError) in
            let raw = try item.load(.xattr(name)) as [UInt8]
            return raw.withUnsafeBytes { bytes in
                let data = Data(bytesNoCopy: .init(mutating: bytes.baseAddress!), count: raw.count, deallocator: .none)
                return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            }
        }
    }
}
#endif
