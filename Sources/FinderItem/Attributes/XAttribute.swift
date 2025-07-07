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
    /// - throws ``XAttributeLoadError``
    ///
    /// - Tip: You can `detailedPrint` `self` with the ``DescriptionConfiguration/showAttributes`` option to view all attributes.
    public func load<T>(_ attributeKey: XAttributeKey<T>) throws(FinderItem.XAttributeLoadError) -> T {
        try attributeKey.load(self)
    }
    
    public struct XAttributeKey<Value> {
        
        let load: (_ source: FinderItem) throws(FinderItem.XAttributeLoadError) -> Value
        
        
        init(load: @escaping (_: FinderItem) throws(FinderItem.XAttributeLoadError) -> Value) {
            self.load = load
        }
        
    }
    
    
    /// An error indicating loading extended attribute resulted in failure.
    ///
    /// To obtain the nature of the error, use `==` to test against the common cases.
    /// ```swift
    /// catch {
    ///     error == .noSuchAttribute
    /// }
    /// ```
    public struct XAttributeLoadError: GenericError, Equatable {
        
        /// The error code associated with the error.
        ///
        /// > SeeAlso:
        /// > ```sh
        /// > $ man listxattr
        /// > ```
        /// > ```sh
        /// > $ man getxattr
        /// > ```
        public let code: Int32
        
        /// The message from the error code.
        public var message: String {
            String(cString: strerror(code))
        }
        
        init(code: Int32) {
            self.code = code
        }
        
        
        /// The extended attribute does not exist.
        public static var noSuchAttribute: XAttributeLoadError {
            XAttributeLoadError(code: ENOATTR)
        }
        
        /// The file system does not support extended attributes or has the feature disabled.
        public static var operationNotSupported: XAttributeLoadError {
            XAttributeLoadError(code: ENOTSUP)
        }
        
        /// The named attribute is not permitted for this type of object.
        public static var operationNotPermitted: XAttributeLoadError {
            XAttributeLoadError(code: EPERM)
        }
        
        /// `name` is invalid.
        public static var invalidName: XAttributeLoadError {
            XAttributeLoadError(code: EINVAL)
        }
        
        /// `self` does not refer to a regular file and the attribute in question is only applicable to files.
        public static var notAFile: XAttributeLoadError {
            XAttributeLoadError(code: EISDIR)
        }
        
        /// A component of `self`'s prefix is not a directory.
        public static var notADirectory: XAttributeLoadError {
            XAttributeLoadError(code: ENOTDIR)
        }
        
        /// Search permission is denied for a component of `self` or the attribute is not allowed to be read (e.g. an ACL prohibits reading the attributes of this file).
        public static var accessDenied: XAttributeLoadError {
            XAttributeLoadError(code: EACCES)
        }
        
        /// `self` points to an invalid address.
        public static var badAddress: XAttributeLoadError {
            XAttributeLoadError(code: EFAULT)
        }
        
        /// An I/O error occurred while reading from or writing to the file system.
        public static var ioError: XAttributeLoadError {
            XAttributeLoadError(code: EIO)
        }
    }
    
}


extension FinderItem.XAttributeKey {
    
    /// Returns the extended attribute keys associated with `self`.
    ///
    /// - Returns: `[]` when there aren't any attributes associated with `self`.
    public static var xattr: FinderItem.XAttributeKey< [String]> {
        .init { source throws (FinderItem.XAttributeLoadError) in
            let bufferSize = listxattr(source.path, nil, 0, 0)
            if bufferSize == 0 {
                return []
            } else if bufferSize == -1 {
                throw FinderItem.XAttributeLoadError(code: errno)
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
    public static func xattr(_ name: String) -> FinderItem.XAttributeKey<[UInt8]> {
        .init { item throws (FinderItem.XAttributeLoadError) in
            let size = getxattr(item.path, name, nil, 0, 0, 0)
            if size == -1 {
                throw FinderItem.XAttributeLoadError(code: errno)
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
    public static func xattr(_ name: String, as type: Value.Type = Value.self) -> FinderItem.XAttributeKey<String?> {
        FinderItem.XAttributeKey { item throws(FinderItem.XAttributeLoadError) in
            let raw = try item.load(.xattr(name)) as [UInt8]
            return String(bytes: raw, encoding: .utf8)
        }
    }
    
    /// Returns the extended attribute associated with the given `name` as a property list, or `nil` if the data is not a property list.
    ///
    /// - Note: You do not use this function directly, you pass it to ``FinderItem/load(_:)``
    public static func xattr(_ name: String, as type: Value.Type = Value.self) -> FinderItem.XAttributeKey<Any?> {
        FinderItem.XAttributeKey { item throws(FinderItem.XAttributeLoadError) in
            let raw = try item.load(.xattr(name)) as [UInt8]
            return raw.withUnsafeBytes { bytes in
                let data = Data(bytesNoCopy: .init(mutating: bytes.baseAddress!), count: raw.count, deallocator: .none)
                return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            }
        }
    }
}


extension FinderItem.XAttributeKey  {
    
    /// The downloaded date.
    ///
    /// Corresponds to `com.apple.metadata:kMDItemDownloadedDate`.
    public static var dateDownloaded: FinderItem.XAttributeKey<Optional<Date>> {
        FinderItem.XAttributeKey { item throws(FinderItem.XAttributeLoadError) in
            guard let plist = try item.load(.xattr("com.apple.metadata:kMDItemDownloadedDate", as: Any?.self)) else { return nil }
            return (plist as! NSArray)[0] as! NSDate as Date
        }
    }
    
    /// The download where from.
    ///
    /// Corresponds to `com.apple.metadata:kMDItemWhereFroms`.
    public static var origin: FinderItem.XAttributeKey<Optional<[String]>> {
        FinderItem.XAttributeKey { item throws(FinderItem.XAttributeLoadError) in
            guard let plist = try item.load(.xattr("com.apple.metadata:kMDItemWhereFroms", as: Any?.self)) else { return nil }
            return (plist as! NSArray).map { $0 as! String }
        }
    }
    
}

#endif
