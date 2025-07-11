//
//  XAttributeError.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-07.
//

#if canImport(Darwin)
import Darwin
import Foundation
import Essentials

extension FinderItem {
    
    /// An error indicating loading extended attribute resulted in failure.
    ///
    /// To determine the nature of the error, use `==` to test against the common cases.
    /// ```swift
    /// catch {
    ///     error == .noSuchAttribute
    /// }
    /// ```
    public struct XAttributeError: GenericError, Equatable {
        
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
        @inlinable
        public var message: String {
            String(cString: strerror(code))
        }
        
        /// Creates an error from the error code.
        @inlinable
        public init(code: Int32) {
            self.code = code
        }
        
        /// Returns the error from the given error code.
        @inlinable
        public static func code(_ code: Int32) -> XAttributeError {
            XAttributeError(code: code)
        }
        
        /// The extended attribute does not exist.
        @inlinable
        public static var noSuchAttribute: XAttributeError {
            XAttributeError(code: ENOATTR)
        }
        
        /// The file system does not support extended attributes or has the feature disabled.
        @inlinable
        public static var operationNotSupported: XAttributeError {
            XAttributeError(code: ENOTSUP)
        }
        
        /// The named attribute is not permitted for this type of object.
        ///
        /// When required from insertion, it tells that attributes cannot be associated with this type of object. For example, attributes are not allowed for resource forks.
        @inlinable
        public static var operationNotPermitted: XAttributeError {
            XAttributeError(code: EPERM)
        }
        
        /// `name` is invalid.
        ///
        /// `name` must be valid UTF-8.
        @inlinable
        public static var invalidName: XAttributeError {
            XAttributeError(code: EINVAL)
        }
        
        /// `self` does not refer to a regular file and the attribute in question is only applicable to files.
        @inlinable
        public static var notAFile: XAttributeError {
            XAttributeError(code: EISDIR)
        }
        
        /// A component of `self`'s prefix is not a directory.
        @inlinable
        public static var notADirectory: XAttributeError {
            XAttributeError(code: ENOTDIR)
        }
        
        /// Search permission is denied for a component of `self` or the attribute is not allowed to be read (e.g. an ACL prohibits reading the attributes of this file).
        @inlinable
        public static var accessDenied: XAttributeError {
            XAttributeError(code: EACCES)
        }
        
        /// `self` points to an invalid address.
        @inlinable
        public static var badAddress: XAttributeError {
            XAttributeError(code: EFAULT)
        }
        
        /// An I/O error occurred while reading from or writing to the file system.
        @inlinable
        public static var ioError: XAttributeError {
            XAttributeError(code: EIO)
        }
        
        
        // MARK: - Insert
        
        /// The file system is mounted read-only.
        @inlinable
        public static var readOnlyFileSystem: XAttributeError {
            XAttributeError(code: EROFS)
        }
        
        /// The data size of the attribute is out of range (some attributes have size restrictions).
        @inlinable
        public static var sizeExceeded: XAttributeError {
            XAttributeError(code: ERANGE)
        }
        
        /// The `name` exceeded `XATTR_MAXNAMELEN` UTF-8 bytes, or a component of path exceeded `NAME_MAX` characters, or the entire path exceeded `PATH_MAX` characters.
        @inlinable
        public static var nameTooLong: XAttributeError {
            XAttributeError(code: ENAMETOOLONG)
        }
        
        /// The data size of the extended attribute is too large.
        @inlinable
        public static var sizeTooLarge: XAttributeError {
            XAttributeError(code: E2BIG)
        }
        
        /// Not enough space left on the file system.
        @inlinable
        public static var noSpace: XAttributeError {
            XAttributeError(code: ENOSPC)
        }
    }
    
}
#endif
