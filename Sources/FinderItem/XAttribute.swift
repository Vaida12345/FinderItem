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


public extension FinderItem {
    
    /// The extended resources associated with this file.
    var extendedAttributes: ExtendedResources? {
        ExtendedResources(item: self)
    }
    
    
    final class ExtendedResources: DetailedStringConvertible {
        
        let item: FinderItem
        
        let attributeBufferSize: Int
        
        /// The attribute keys associated with this item.
        ///
        /// - Tip: use `detailedPrint` to view the hierarchy.
        public lazy var attributeKeys: [String] = computeAttributeKeys()
        
        init?(item: FinderItem) {
            let bufferSize = listxattr(item.path, nil, 0, 0)
            guard bufferSize > 0 else { return nil }
            
            self.attributeBufferSize = bufferSize
            self.item = item
        }
        
        
        func computeAttributeKeys() -> [String] {
            let namebuf = [CChar](unsafeUninitializedCapacity: attributeBufferSize) { buffer, initializedCount in
                listxattr(item.path, buffer.baseAddress, attributeBufferSize, 0)
                initializedCount = attributeBufferSize
            }
            
            return namebuf.split(separator: 0).compactMap {
                return String(decoding: $0.map(UInt8.init), as: UTF8.self)
            }
        }
        
        public func detailedDescription(using descriptor: DetailedDescription.Descriptor<FinderItem.ExtendedResources>) -> any DescriptionBlockProtocol {
            descriptor.container {
                descriptor.forEach(attributeKeys) { key in
                    if let data = self[key] {
                        if let plist = data.cast(to: .propertyList) {
                            descriptor.container(key) {
                                descriptor.value("", of: plist)
                            }
                        } else if let string = data.cast(to: .string) {
                            descriptor.value(key, of: string)
                        } else {
                            descriptor.value(key, of: "<binary data>")
                        }
                    } else {
                        descriptor.value(key, of: "<no value>")
                    }
                }
            }
        }
        
        
        /// The downloaded date.
        ///
        /// Corresponds to `com.apple.metadata:kMDItemDownloadedDate`.
        public var dateDownloaded: Date? {
            guard let date = self["com.apple.metadata:kMDItemDownloadedDate"]?.cast(to: .propertyList) else { return nil }
            return (date as! NSArray)[0] as! NSDate as Date
        }
        
        /// The download where from.
        ///
        /// Corresponds to `com.apple.metadata:kMDItemWhereFroms`.
        public var origin: [String]? {
            guard let date = self["com.apple.metadata:kMDItemWhereFroms"]?.cast(to: .propertyList) else { return nil }
            return (date as! NSArray).map { $0 as! String }
        }
        
        
        /// Find the value associated with `key`.
        ///
        /// - SeeAlso: ``subscript(_:as:)``
        ///
        /// - Tip: use `detailedPrint` to view the hierarchy.
        public subscript(_ key: String) -> Property? {
            let size = getxattr(item.path, key, nil, 0, 0, 0)
            guard size > 0 else { return nil }
            
            let data = [UInt8](unsafeUninitializedCapacity: size) { buffer, initializedCount in
                getxattr(item.path, key, buffer.baseAddress, size, 0, 0)
                initializedCount = size
            }
            return Property(raw: data)
        }
        
        
        public struct Property: Sendable {
            
            /// The raw bytes.
            public let raw: [UInt8]
            
            
            /// Casts as property list
            public func cast<T>(to type: CastableType<T>) -> T? where T: Any {
                return raw.withUnsafeBytes { bytes in
                    let data = Data(bytesNoCopy: .init(mutating: bytes.baseAddress!), count: raw.count, deallocator: .none)
                    return try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? T
                }
            }
            
            /// Casts as string
            public func cast(to type: CastableType<String>) -> String? {
                return String(bytes: raw, encoding: .utf8)
            }
            
            
            public struct CastableType<Value> { }
            
        }
        
    }
    
}

public extension FinderItem.ExtendedResources.Property.CastableType where Value == String {
    
    /// Indicates the value is a `String`.
    static var string: Self { Self() }
    
}

public extension FinderItem.ExtendedResources.Property.CastableType where Value == Any {
    
    /// Indicates the value is a property list.
    static var propertyList: Self { Self() }
    
}
#endif
