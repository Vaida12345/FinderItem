//
//  Attributes + fm.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


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
    
    /// The group name of the file’s owner.
    @inlinable
    public var groupOwner: String? {
        self._fm_attributes[.groupOwnerAccountName] as? String
    }
    
    /// Whether the file is immutable.
    @inlinable
    public var readOnly: Bool? {
        self._fm_attributes[.immutable] as? Bool
    }
    
    /// Whether the file is append-only.
    @inlinable
    public var appendOnly: Bool? {
        self._fm_attributes[.appendOnly] as? Bool
    }
    
    /// Whether the file’s extension is hidden.
    @inlinable
    public var extensionHidden: Bool? {
        self._fm_attributes[.extensionHidden] as? Bool
    }
}
