//
//  Attributes + fm.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation
import System


extension FinderItem.Attributes {
    
    /// The file’s size in bytes.
    ///
    /// If the file has a resource fork, the returned value does not include the size of the resource fork.
    @inlinable
    public var fileSize: UInt? {
        self._fm_attributes[.size] as? UInt
    }
    
    /// The file’s last modified date.
    ///
    /// - Important: This API has the potential of being misused to access device signals to try to identify the device or user, also known as fingerprinting. Regardless of whether a user gives your app permission to track, fingerprinting is not allowed. When you use this API in your app or third-party SDK (an SDK not provided by Apple), declare your usage and the reason for using the API in your app or third-party SDK’s `PrivacyInfo.xcprivacy` file. For more information, including the list of valid reasons for using the API, see [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
    @inlinable
    public var modificationDate: Date? {
        self._fm_attributes[.modificationDate] as? Date
    }
    
    /// The file’s creation date.
    ///
    /// - Important: This API has the potential of being misused to access device signals to try to identify the device or user, also known as fingerprinting. Regardless of whether a user gives your app permission to track, fingerprinting is not allowed. When you use this API in your app or third-party SDK (an SDK not provided by Apple), declare your usage and the reason for using the API in your app or third-party SDK’s `PrivacyInfo.xcprivacy` file. For more information, including the list of valid reasons for using the API, see [Describing use of required reason API](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
    @inlinable
    public var creationDate: Date? {
        self._fm_attributes[.creationDate] as? Date
    }
    
    /// The number of hard links to a file.
    @inlinable
    public var referenceCount: UInt? {
        self._fm_attributes[.referenceCount] as? UInt
    }
    
    /// The name of the file’s owner.
    @inlinable
    public var owner: String? {
        self._fm_attributes[.ownerAccountName] as? String
    }
    
    /// Group name of the file’s owner.
    @inlinable
    public var groupOwner: String? {
        self._fm_attributes[.groupOwnerAccountName] as? String
    }
    
    /// Whether the file is immutable.
    @inlinable
    public var readOnly: Bool {
        self._fm_attributes[.immutable] as? Bool ?? false
    }
    
    /// Whether the file is append Only.
    @inlinable
    public var appendOnly: Bool {
        self._fm_attributes[.appendOnly] as? Bool ?? false
    }
    
    /// Whether the file’s extension is hidden.
    @inlinable
    public var extensionHidden: Bool? {
        self._fm_attributes[.extensionHidden] as? Bool
    }
}


// MARK: - xattr
// Cannot use `FileManager` xattr, as certain values are omitted.

extension FinderItem.Attributes {
    
    /// Returns all of extended attribute keys associated with `self`.
    ///
    /// - throws: Error in retrieval process.
    ///
    /// - Returns: `[]` when there aren't any attributes associated with `self`.
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
    /// - throws: Error in retrieval process.
    ///
    /// - SeeAlso: Use ``xattr(_:as:)`` to parse as `String?` or property list (`Any?`).
    ///
    /// - Returns: Empty data when there aren't any value associated with `name`.
    @inlinable
    public func xattr(_ name: String) throws(Errno) -> Data {
        let size = getxattr(self.parent.path, name, nil, 0, 0, 0)
        if size == -1 {
            throw Errno(rawValue: errno)
        }
        
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: size)
        getxattr(self.parent.path, name, buffer.baseAddress, size, 0, 0)
        
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
    /// - throws: Error in retrieval process.
    ///
    /// - SeeAlso: Use ``xattr(_:)`` to read the value as it is.
    ///
    /// - returns: `nil` only when data is not a `String`.
    @inlinable
    public func xattr<T>(_ name: String, as type: T.Type = String.self) throws(Errno) -> String? {
        let raw = try self.xattr(name)
        return String(bytes: raw, encoding: .utf8)
    }
    
    /// Returns whether the file has a custom icon.
    @inlinable
    public var hasCustomIcon: Bool {
        get throws(Errno) {
            let info = try self.xattr("com.apple.FinderInfo")
            return info[8] & 0x04 != 0
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
    
    /// The file (download) where from.
    ///
    /// - SeeAlso: ``dateDownloaded``
    @inlinable
    public var origin: [String]? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemWhereFroms")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.compactMap { $0 as? String }
        }
    }
    
    /// Finder comments on this file.
    ///
    /// - Experiment: Finder may have a hard time loading the modified comments.
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
    
    /// Application used to convert the original content into it's current form.
    ///
    /// For example, a PDF file might have an encoding application set to "Distiller"
    @inlinable
    public var encodingApplications: [String]? {
        get throws(Errno) {
            let data = try self.xattr("com.apple.metadata:kMDItemEncodingApplications")
            let properyList = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            return (properyList as? NSArray)?.compactMap { $0 as? String }
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
    /// - Experiment: This method updates the `Finder` database alright, but it is not reflected on GUI.
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
        
        /// An emoji
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
