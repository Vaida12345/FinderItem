//
//  Attributes + Update.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem.Attributes {
    
    /// Inserts or replaces an attribute value.
    @inlinable
    public func update<T, E: Error>(_ attribute: InsertableAttributeKey<T, E>, to value: T) throws(E) {
        try attribute.insertTo(self.parent, value)
    }
    
    public struct InsertableAttributeKey<Value, E: Error> {
        
        /// Writes `value` to `item`.
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
import Darwin
import System

extension FinderItem.Attributes.InsertableAttributeKey where E == any Error {
    
    @inlinable
    init(_ key: String, properlyListSerializing transform: @escaping (Value) -> Any) {
        self.init { item, value in
            let data = try PropertyListSerialization.data(fromPropertyList: transform(value), format: .xml, options: 0)
            
            let code = data.withUnsafeBytes { bytes in
                setxattr(item.path, key, bytes.baseAddress, bytes.count, 0, 0)
            }
            guard code == 0 else {
                throw Errno(rawValue: errno)
            }
        }
    }
    
}

extension FinderItem.Attributes.InsertableAttributeKey where Value == Data {
    
    /// Inserts an extended attribute with the given `name`.
    @inlinable
    public static func xattr(_ name: String) -> FinderItem.Attributes.InsertableAttributeKey<Data, Errno> {
        .init { item, value throws(Errno) in
            let code = value.withUnsafeBytes { bytes in
                setxattr(item.path, name, bytes.baseAddress, bytes.count, 0, 0)
            }
            guard code == 0 else {
                throw Errno(rawValue: errno)
            }
        }
    }
}

extension FinderItem.Attributes.InsertableAttributeKey where Value == Date {
    
    /// The downloaded date.
    ///
    /// - SeeAlso: ``origin``
    @inlinable
    public static var downloadDate: FinderItem.Attributes.InsertableAttributeKey<Date, any Error> {
        .init("com.apple.metadata:kMDItemDownloadedDate", properlyListSerializing: { [$0] })
    }
}

extension FinderItem.Attributes.InsertableAttributeKey where Value == [String] {
    
    /// Keywords associated with this file.
    ///
    /// - Experiment: Finder may show the keywords in a reversed order.
    @inlinable
    public static var keywords: FinderItem.Attributes.InsertableAttributeKey<[String], any Error> {
        .init("com.apple.metadata:kMDItemKeywords", properlyListSerializing: { $0 })
    }
    
    /// Tags set by user.
    @inlinable
    public static var tags: FinderItem.Attributes.InsertableAttributeKey<[String], any Error> {
        .init("com.apple.metadata:_kMDItemUserTags", properlyListSerializing: { $0 })
    }
}

extension FinderItem.Attributes.InsertableAttributeKey where Value == String {
    
    /// The source URL recorded for a downloaded file.
    ///
    /// - SeeAlso: ``downloadDate``
    @inlinable
    public static var origin: FinderItem.Attributes.InsertableAttributeKey<String, any Error> {
        .init("com.apple.metadata:kMDItemWhereFroms", properlyListSerializing: { [$0] })
    }
    
    /// Finder comments on this file.
    ///
    /// - Experiment: Finder may have a hard time loading the modified comments.
    @inlinable
    public static var comments: FinderItem.Attributes.InsertableAttributeKey<String, any Error> {
        .init("com.apple.metadata:kMDItemFinderComment", properlyListSerializing: { $0 })
    }
    
    /// A description of the content of the resource.
    ///
    /// The description may include an abstract, table of contents, reference to a graphical representation of content or a free-text account of the content.
    @inlinable
    public static var fileDescription: FinderItem.Attributes.InsertableAttributeKey<String, any Error> {
        .init("com.apple.metadata:kMDItemDescription", properlyListSerializing: { $0 })
    }
    
    /// The application used to convert the original content into its current form.
    ///
    /// For example, a PDF file might have an encoding application set to "Distiller"
    @inlinable
    public static var encodingApplications: FinderItem.Attributes.InsertableAttributeKey<String, any Error> {
        .init("com.apple.metadata:kMDItemEncodingApplications", properlyListSerializing: { [$0] })
    }
}

extension FinderItem.Attributes.InsertableAttributeKey where Value == FinderItem.Attributes.XAttributeIcon {
    
    /// Inserts the icon attribute stored in `xattr`.
    ///
    /// - Experiment: This method updates the `Finder` database alright, but it is not reflected in the Finder app.
    public static var xattrIcon: FinderItem.Attributes.InsertableAttributeKey<FinderItem.Attributes.XAttributeIcon, any Error> {
        .init { item, value in
            let code = try value.data.withUnsafeBytes { bytes in
                setxattr(item.path, "com.apple.icon.folder#S", bytes.baseAddress, bytes.count, 0, 0)
            }
            guard code == 0 else {
                throw Errno(rawValue: errno)
            }
        }
    }
    
}
#endif


// MARK: - URL

#if os(macOS)
extension FinderItem.Attributes.InsertableAttributeKey where Value == [String : Any]? {
    
    /// The quarantine properties as defined in `LSQuarantine.h`.
    ///
    /// Set this value to `nil` to remove quarantine.
    public static var quarantine: FinderItem.Attributes.InsertableAttributeKey<[String : Any]?, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.quarantineProperties = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
}

extension FinderItem.Attributes.InsertableAttributeKey where Value == Bool {
    
    /// Returns `true` for resources normally not displayed to users.
    public static var isHidden: FinderItem.Attributes.InsertableAttributeKey<Bool, any Error> {
        .init { item, value in
            var resourceValues = URLResourceValues()
            resourceValues.isHidden = value
            try item.url.setResourceValues(resourceValues)
        }
    }
    
}
#endif
