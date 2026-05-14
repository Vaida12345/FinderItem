//
//  Attributes + xattr.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

#if canImport(Darwin)
import Darwin
import Foundation
import System


// Cannot use `FileManager` xattr, as certain values are omitted.
extension FinderItem.Attributes {
    
    /// Returns all extended-attribute keys associated with this item.
    ///
    /// - Throws: An error if retrieval fails.
    ///
    /// - Returns: `[]` when no extended attributes are present.
    @inlinable
    public var xattr: [String] {
        get throws(Errno) {
            let bufferSize = listxattr(self.parent.path, nil, 0, 0)
            if bufferSize == 0 {
                return []
            } else if bufferSize == -1 {
                throw Errno(rawValue: errno)
            }
            
            let namebuf = [CChar](unsafeUninitializedCapacity: bufferSize) { buffer, initializedCount in
                listxattr(self.parent.path, buffer.baseAddress, bufferSize, 0)
                initializedCount = bufferSize
            }
            
            return namebuf.split(separator: 0).compactMap {
                return String(decoding: $0.map(UInt8.init), as: UTF8.self)
            }
        }
    }
    
    /// Returns the extended attribute associated with the given `name` as unparsed raw data.
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    ///
    /// - Throws: An error if retrieval fails.
    ///
    /// - SeeAlso: Use ``xattr(_:as:)`` to parse as `String?` or property list (`Any?`).
    ///
    /// - Returns: Empty data when no value is associated with `name`.
    @inlinable
    public func xattr(_ name: String) throws(Errno) -> Data {
        let size = getxattr(self.parent.path, name, nil, 0, 0, 0)
        if size == -1 {
            throw Errno(rawValue: errno)
        }
        
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size)
        let status = getxattr(self.parent.path, name, buffer.baseAddress, size, 0, 0)
        if status == -1 {
            buffer.deallocate()
            throw Errno(rawValue: errno)
        }
        
        return Data(bytesNoCopy: buffer.baseAddress!, count: size, deallocator: .free)
    }
    
    /// Returns the extended attribute associated with the given `name` as a `String`, or `nil` if the data is not a `String`.
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    ///
    /// - Throws: An error if retrieval fails.
    ///
    /// - SeeAlso: Use ``xattr(_:)`` to read the value as it is.
    ///
    /// - Returns: `nil` when the attribute data is not valid UTF-8 text.
    @inlinable
    public func xattr<T>(_ name: String, as type: T.Type = String.self) throws(Errno) -> String? {
        let raw = try self.xattr(name)
        return String(bytes: raw, encoding: .utf8)
    }
    
    /// Returns whether the file has a custom icon.
    ///
    /// - Returns: `false` if the attribute is not found.
    @inlinable
    public var hasCustomIcon: Bool {
        get throws(Errno) {
            do {
                let info = try self.xattr("com.apple.FinderInfo")
                guard info.count > 8 else { return false }
                return info[8] & 0x04 != 0
            } catch .attributeNotFound {
                return false
            }
        }
    }
    
    
    /// The downloaded date.
    ///
    /// - SeeAlso: ``origin``
    @inlinable
    public var downloadDate: Date? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemDownloadedDate")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.firstObject as? Date
        }
    }
    
    /// The source URL recorded for a downloaded file.
    ///
    /// - SeeAlso: ``downloadDate``
    @inlinable
    public var origin: String? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemWhereFroms")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.firstObject as? String
        }
    }
    
    /// Finder comments on this file.
    @inlinable
    public var comments: String? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemFinderComment")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return properyList as? String
        }
    }
    
    /// Keywords associated with this file.
    ///
    /// - Experiment: Finder may show the keywords in a reversed order.
    @inlinable
    public var keywords: [String]? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemKeywords")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.compactMap { $0 as? String }
        }
    }
    
    /// A description of the content of the resource.
    ///
    /// The description may include an abstract, table of contents, reference to a graphical representation of content or a free-text account of the content.
    @inlinable
    public var fileDescription: String? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemDescription")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return properyList as? String
        }
    }
    
    /// The application used to convert the original content into its current form.
    ///
    /// For example, a PDF file might have an encoding application set to "Distiller"
    @inlinable
    public var encodingApplications: String? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemEncodingApplications")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.firstObject as? String
        }
    }
    
    /// Tags set by user.
    @inlinable
    public var tags: [String]? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:_kMDItemUserTags")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.compactMap { $0 as? String }
        }
    }
    
    /// The icon attribute, read from `xattr`.
    ///
    /// - Experiment: This method updates the `Finder` database alright, but it is not reflected in the Finder app.
    @inlinable
    public var xattrIcon: XAttributeIcon? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.icon.folder#S")
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String : String] else { return nil }
            if let value = json["sym"] {
                return .systemImage(value)
            } else if let value = json["emoji"] {
                return .emoji(value)
            } else {
                return nil
            }
        }
    }
    
    /// The icon attribute, read from `xattr`.
    public enum XAttributeIcon {
        /// A system-defined image.
        ///
        /// See `SF Symbols` for details.
        case systemImage(String)
        
        /// An emoji.
        case emoji(String)
        
        
        internal var data: Data {
            get throws {
                let raw = switch self {
                case .systemImage(let name):
                    ["sym" : name]
                case .emoji(let string):
                    ["emoji" : string]
                }
                
                return try JSONSerialization.data(withJSONObject: raw)
            }
        }
    }
    
}
#endif
