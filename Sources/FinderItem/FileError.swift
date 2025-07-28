//
//  FinderItem + Error.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/4/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import Darwin
import Essentials


extension FinderItem {
    
    /// A file operation error.
    ///
    /// Although `FileError` is `Equatable`, you should use the error code to determine the nature of the error.
    ///
    /// ```swift
    /// if fileError.code == .cannotRead(reason: .noSuchFile) {
    ///     ...
    /// }
    /// ```
    ///
    /// You can also determine the nature of the error without specifying the reason.
    /// ```swift
    /// if case .cannotRead = fileError.code {
    ///     ...
    /// }
    /// ```
    ///
    /// ## Topics
    /// ### Properties
    /// - ``code``
    /// - ``source``
    ///
    /// ### Initializers
    /// - ``init(code:source:underlyingError:)``
    /// - ``parse(_:)``
    ///
    /// ### Error Information
    /// - ``title``
    /// - ``message``
    public struct FileError: GenericError {
        
        /// The error code.
        ///
        /// You should use the error code to determine the nature of the error.
        ///
        /// ```swift
        /// if fileError.code == .cannotRead(reason: .noSuchFile) {
        ///     ...
        /// }
        /// ```
        ///
        /// You can also determine the nature of the error without specifying the reason.
        /// ```swift
        /// if case .cannotRead = fileError.code {
        ///     ...
        /// }
        /// ```
        public let code: Code
        
        /// The file that caused the error.
        public let source: FinderItem
        
        /// The unparsed original error.
        public let underlyingError: (any Error)?
        
        
        @inlinable
        public static func == (lhs: FileError, rhs: FileError) -> Bool {
            lhs.code == rhs.code && lhs.source == rhs.source
        }
        
        
        /// An error code.
        ///
        /// You should use the error code to determine the nature of the error.
        ///
        /// ```swift
        /// if fileError.code == .cannotRead(reason: .noSuchFile) {
        ///     ...
        /// }
        /// ```
        ///
        /// You can also determine the nature of the error without specifying the reason.
        /// ```swift
        /// if case .cannotRead = fileError.code {
        ///     ...
        /// }
        /// ```
        public enum Code: Equatable, Sendable {
            /// The error code indicates that the volume cannot be unmounted.
            case cannotUnmount(reason: UnmountFailureReason)
            
            /// The error code indicating the file is unreadable.
            case cannotRead(reason: ReadFailureReason)
            
            /// The error code indicating the file is unwritable.
            case cannotWrite(reason: WriteFailureReason)
            
            /// The error code indicating the an intermediate file does not exist.
            case intermediateFileNotExist
            
            /// The error code indicating failure in parsing such value.
            ///
            /// In this case, the `source` is always the home directory.
            case unknown
            
            
            /// The reason for the failure to unmount.
            public enum UnmountFailureReason: Sendable {
                /// The volume couldn’t be unmounted because it’s in use.
                case busy
                /// The volume couldn't be unmounted, for unknown reasons.
                case unknown
            }
            
            /// The reason for the failure to read a file.
            public enum ReadFailureReason: Sendable {
                /// Could not read because of a corrupted file, bad format, or similar reason.
                case corruptFile
                /// Could not read because the string encoding wasn’t applicable.
                case inapplicableStringEncoding
                /// Could not read because of an invalid file name.
                case invalidFileName
                /// Could not read because of a permission problem.
                case noPermission
                /// Could not read because no such file was found.
                case noSuchFile
                /// Could not read because the specified file was too large.
                case tooLarge
                /// Could not read, for unknown reasons.
                case unknown
                /// Could not read because the string coding of the file couldn’t be determined.
                case unknownStringEncoding
                /// Could not read because the specified URL scheme is unsupported.
                case unsupportedScheme
                
                /// Creates a reason based on a POSIX `errno` code.
                ///
                /// - Note: A one-to-one matching cannot be not guaranteed, as this structure primarily aims to serve the Swift suite of errors. Notably, `EBADF` is ignored.
                @inlinable
                public static func posix(code: Int32) -> ReadFailureReason {
                    switch code {
                    case EACCES: .noPermission
                    case ENAMETOOLONG, ENOENT: .invalidFileName
                    default: .unknown
                    }
                }
            }
            
            /// The reason for the failure to write a file.
            public enum WriteFailureReason: Sendable {
                /// Could not perform an operation because the destination file already exists.
                case fileExists
                /// Could not write because the string encoding was not applicable.
                case inapplicableStringEncoding
                /// Could not write because of an invalid file name.
                case invalidFileName
                /// Could not write because of a permission problem.
                case noPermission
                /// Could not write because of a lack of disk space.
                case outOfSpace
                /// Could not write, for unknown reasons.
                case unknown
                /// Could not write because the specified URL scheme is unsupported.
                case unsupportedScheme
                /// Could not write because the volume is read-only.
                case volumeReadOnly
            }
        }
        
        /// The title of the error.
        @inlinable
        public var title: String {
            switch code {
            case .cannotUnmount:
                "Cannot unmount volume \"\(source.name)\""
            case .cannotRead:
                "Unable to read \"\(source.name)\""
            case .cannotWrite:
                "Unable to write to \"\(source.name)\""
            case .intermediateFileNotExist:
                "An intermediate file does not exist"
            case .unknown:
                (underlyingError as? NSError)?.localizedDescription ?? "(unknown)"
            }
        }
        
        @inlinable
        public var message: String {
            if let underlyingError = underlyingError as? CocoaError {
                return underlyingError.localizedDescription
            }
            
            return switch code {
            case let .cannotUnmount(reason):
                switch reason {
                case .busy:
                    "The volume is in use."
                case .unknown:
                    "Unknown reason"
                }
                
            case let .cannotRead(reason):
                switch reason {
                case .noSuchFile:
                    "The file \"\(source)\" does not exist."
                case .corruptFile:
                    "The file \"\(source)\" is corrupted or in a bad format."
                case .inapplicableStringEncoding:
                    "The file \"\(source)\" employs an inapplicable string encoding."
                case .invalidFileName:
                    "The file path \"\(source)\" possesses an invalid filename."
                case .noPermission:
                    "You do not have permission to read file \"\(source)\"."
                case .tooLarge:
                    "The file \"\(source)\" is too large."
                case .unknown:
                    "Unknown reason for file \"\(source)\"."
                case .unknownStringEncoding:
                    "The file \"\(source)\" employs an unknown string encoding."
                case .unsupportedScheme:
                    "The file path \"\(source)\" employs an unsupported URL scheme."
                }
                
            case let .cannotWrite(reason):
                switch reason {
                case .fileExists:
                    "The file \"\(source)\" already exists."
                case .inapplicableStringEncoding:
                    "The file \"\(source)\" employs an inapplicable string encoding."
                case .invalidFileName:
                    "The file path \"\(source)\" possesses an invalid filename."
                case .noPermission:
                    "You do not have permission to write to file \"\(source)\"."
                case .outOfSpace:
                    "Insufficient disk space to write to file \(source)."
                case .unknown:
                    "Unknown reason for file \"\(source)\"."
                case .unsupportedScheme:
                    "The file path \"\(source)\" employs an unsupported URL scheme."
                case .volumeReadOnly:
                    "The volume of file \"\(source)\" is read-only."
                }
                
            case .intermediateFileNotExist:
                "No such file or directory for an intermediate file of \"\(source)\"."
                
            case .unknown:
                "(unknown)"
            }
        }
        
        
        @inlinable
        public init(code: Code, source: FinderItem, underlyingError: Error? = nil) {
            self.code = code
            self.source = source
            self.underlyingError = underlyingError
        }
        
        
        /// Parses an error, and convert it into a `FileError`
        ///
        /// - Parameters:
        ///   - error: The source error
        @inlinable
        public static func parse(_ error: some Error) -> FileError {
            if let error = error as? FileError { return error }
            
            guard let error = error as? CocoaError else { return FileError(code: .unknown, source: .homeDirectory, underlyingError: error) }
            guard let url = (error.userInfo["NSDestinationFilePath"] as? String).map({ URL(fileURLWithPath: $0) }) ?? error.url ?? error.filePath.map({ URL(filePath: $0) }) else { return FileError(code: .unknown, source: .homeDirectory, underlyingError: error) }
            let source = FinderItem(at: url)
            
            return switch error.code {
                // File Errors
            case .fileNoSuchFile:
                FileError(code: .intermediateFileNotExist, source: source, underlyingError: error)
#if os(macOS)
            case .fileManagerUnmountBusy:
                FileError(code: .cannotUnmount(reason: .busy), source: source, underlyingError: error)
            case .fileManagerUnmountUnknown:
                FileError(code: .cannotUnmount(reason: .unknown), source: source, underlyingError: error)
#endif
                
                // File Reading Errors
            case .fileReadCorruptFile:
                FileError(code: .cannotRead(reason: .corruptFile), source: source, underlyingError: error)
            case .fileReadInapplicableStringEncoding:
                FileError(code: .cannotRead(reason: .inapplicableStringEncoding), source: source, underlyingError: error) // , additionalInfo: [NSStringEncodingErrorKey : error.userInfo[NSStringEncodingErrorKey] as! String]
            case .fileReadInvalidFileName:
                FileError(code: .cannotRead(reason: .invalidFileName), source: source, underlyingError: error)
            case .fileReadNoPermission:
                FileError(code: .cannotRead(reason: .noPermission), source: source, underlyingError: error)
            case .fileReadNoSuchFile:
                FileError(code: .cannotRead(reason: .noSuchFile), source: source, underlyingError: error)
            case .fileReadTooLarge:
                FileError(code: .cannotRead(reason: .tooLarge), source: source, underlyingError: error)
            case .fileReadUnknown:
                FileError(code: .cannotRead(reason: .unknown), source: source, underlyingError: error)
            case .fileReadUnknownStringEncoding:
                FileError(code: .cannotRead(reason: .unknownStringEncoding), source: source, underlyingError: error)
            case .fileReadUnsupportedScheme:
                FileError(code: .cannotRead(reason: .unsupportedScheme), source: source, underlyingError: error)
                
                // File Writing Errors
            case .fileWriteFileExists:
                FileError(code: .cannotWrite(reason: .fileExists), source: source, underlyingError: error)
            case .fileWriteInapplicableStringEncoding:
                FileError(code: .cannotWrite(reason: .inapplicableStringEncoding), source: source, underlyingError: error) // , additionalInfo: [NSStringEncodingErrorKey : error.userInfo[NSStringEncodingErrorKey] as! String]
            case .fileWriteInvalidFileName:
                FileError(code: .cannotWrite(reason: .invalidFileName), source: source, underlyingError: error)
            case .fileWriteNoPermission:
                FileError(code: .cannotWrite(reason: .noPermission), source: source, underlyingError: error)
            case .fileWriteOutOfSpace:
                FileError(code: .cannotWrite(reason: .outOfSpace), source: source, underlyingError: error)
            case .fileWriteUnknown:
                FileError(code: .cannotWrite(reason: .unknown), source: source, underlyingError: error)
            case .fileWriteUnsupportedScheme:
                FileError(code: .cannotWrite(reason: .unsupportedScheme), source: source, underlyingError: error)
            case .fileWriteVolumeReadOnly:
                FileError(code: .cannotWrite(reason: .volumeReadOnly), source: source, underlyingError: error)
                
            default:
                FileError(code: .unknown, source: source, underlyingError: error)
            }
        }
        
        /// Parses an error, or throw the argument.
        ///
        /// - Parameters:
        ///   - arg: The source error
        ///
        /// - throws: The argument when parsing failed.
        @inlinable
        public static func parse(orThrow arg: some Error) throws(any Error) -> FileError {
            let error = parse(arg)
            if error.code == .unknown {
                throw arg
            } else {
                return error
            }
        }
        
    }
    
}
