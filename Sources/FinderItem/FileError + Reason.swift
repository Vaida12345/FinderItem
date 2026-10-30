//
//  FileError + Reason.swift
//  FinderItem
//
//  Created by Vaida on 2026-10-30.
//

import Foundation
import System


extension FinderItem.FileError {

    /// The nature of a ``FinderItem/FileError``.
    ///
    /// A reason classifies what went wrong, independent of which API reported it and of whether the file was being read or written. For example, ``noSuchFile`` is the reason for a missing file whether it was `remove()`, `move(to:)`, or `contentType` that noticed.
    ///
    /// ```swift
    /// switch error.reason {
    /// case .noSuchFile:
    ///     ...
    /// case .noPermission:
    ///     ...
    /// default:
    ///     ...
    /// }
    /// ```
    ///
    /// The set of reasons is open: reasons may be added in minor releases, so a `switch` needs a `default`. An error that matches none of the reasons is ``other``. This is not a failure to describe the error: ``FinderItem/FileError/message`` and ``FinderItem/FileError/underlyingError`` always carry everything the system reported.
    public struct Reason: RawRepresentable, Hashable, Sendable, CustomStringConvertible {

        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public var description: String {
            rawValue
        }


        /// The file, or a folder on the way to it, does not exist.
        public static let noSuchFile = Reason(rawValue: "noSuchFile")

        /// The process is not allowed to access the file.
        public static let noPermission = Reason(rawValue: "noPermission")

        /// An item with the same name already exists.
        public static let fileExists = Reason(rawValue: "fileExists")

        /// The directory is not empty.
        public static let directoryNotEmpty = Reason(rawValue: "directoryNotEmpty")

        /// The volume has no space left.
        public static let outOfSpace = Reason(rawValue: "outOfSpace")

        /// The volume is read-only.
        public static let readOnlyVolume = Reason(rawValue: "readOnlyVolume")

        /// The file name is invalid or too long.
        public static let invalidName = Reason(rawValue: "invalidName")

        /// The item is a directory, where a file was expected.
        public static let isDirectory = Reason(rawValue: "isDirectory")

        /// The item is not a directory, where a directory was expected.
        public static let notDirectory = Reason(rawValue: "notDirectory")

        /// The item, or the volume, is in use.
        public static let busy = Reason(rawValue: "busy")

        /// The operation cannot cross volumes.
        public static let differentVolume = Reason(rawValue: "differentVolume")

        /// The file is too large.
        public static let tooLarge = Reason(rawValue: "tooLarge")

        /// The file is corrupted, or in a bad format.
        public static let corruptFile = Reason(rawValue: "corruptFile")

        /// The URL scheme is not supported.
        public static let unsupportedScheme = Reason(rawValue: "unsupportedScheme")

        /// The text encoding is unknown, or cannot represent the contents.
        public static let stringEncoding = Reason(rawValue: "stringEncoding")

        /// The operation was cancelled.
        public static let cancelled = Reason(rawValue: "cancelled")

        /// None of the other reasons applies.
        ///
        /// Inspect ``FinderItem/FileError/underlyingError`` to learn more.
        public static let other = Reason(rawValue: "other")


        /// Every reason, in declaration order.
        static let all: [Reason] = [
            .noSuchFile, .noPermission, .fileExists, .directoryNotEmpty, .outOfSpace, .readOnlyVolume, .invalidName,
            .isDirectory, .notDirectory, .busy, .differentVolume, .tooLarge, .corruptFile, .unsupportedScheme,
            .stringEncoding, .cancelled, .other
        ]

    }

}


// MARK: - Classification

extension FinderItem.FileError.Reason {

    /// Classifies a POSIX error number.
    init?(errno code: Int32) {
        switch code {
        case ENOENT: self = .noSuchFile
        case EACCES, EPERM: self = .noPermission
        case EEXIST: self = .fileExists
        case ENOTEMPTY: self = .directoryNotEmpty
        case ENOSPC, EDQUOT: self = .outOfSpace
        case EROFS: self = .readOnlyVolume
        case ENAMETOOLONG: self = .invalidName
        case EISDIR: self = .isDirectory
        case ENOTDIR: self = .notDirectory
        case EBUSY, ETXTBSY: self = .busy
        case EXDEV: self = .differentVolume
        case EFBIG: self = .tooLarge
        case ECANCELED: self = .cancelled
        default: return nil
        }
    }

    /// Classifies a code of `NSCocoaErrorDomain`.
    init?(cocoa code: Int) {
        switch CocoaError.Code(rawValue: code) {
        case .fileNoSuchFile, .fileReadNoSuchFile: self = .noSuchFile
        case .fileReadNoPermission, .fileWriteNoPermission: self = .noPermission
        case .fileWriteFileExists: self = .fileExists
        case .fileWriteOutOfSpace: self = .outOfSpace
        case .fileWriteVolumeReadOnly: self = .readOnlyVolume
        case .fileReadInvalidFileName, .fileWriteInvalidFileName: self = .invalidName
        case .fileReadCorruptFile: self = .corruptFile
        case .fileReadTooLarge: self = .tooLarge
        case .fileReadUnsupportedScheme, .fileWriteUnsupportedScheme: self = .unsupportedScheme
        case .fileReadInapplicableStringEncoding, .fileWriteInapplicableStringEncoding, .fileReadUnknownStringEncoding: self = .stringEncoding
        case .fileLocking: self = .busy
#if os(macOS)
        case .fileManagerUnmountBusy: self = .busy
#endif
        case .userCancelled: self = .cancelled
        default: return nil
        }
    }

    /// Classifies a code of `NSOSStatusErrorDomain`.
    init?(osStatus code: Int) {
        switch code {
        case -43: self = .noSuchFile // fnfErr
        default: return nil
        }
    }

}


extension FinderItem.FileError {

    /// The errors that led to `error`, outermost first, following `NSUnderlyingErrorKey`.
    static func chain(of error: any Error) -> [NSError] {
        func bridge(_ value: Any?) -> NSError? {
            if let error = value as? NSError { return error }
            if let error = value as? any Error { return error as NSError }
            return nil
        }

        var chain: [NSError] = []
        var current = bridge(error)
        while let error = current, chain.count < 8 {
            chain.append(error)
            current = bridge(error.userInfo[NSUnderlyingErrorKey])
        }
        return chain
    }

    /// Classifies a chain of errors.
    ///
    /// A nested POSIX error wins over the Cocoa code, as the Cocoa code is often generic (such as `NSFileReadUnknownError`). The OSStatus is consulted last.
    static func classify(_ chain: [NSError]) -> Reason {
        for error in chain where error.domain == NSPOSIXErrorDomain {
            if let reason = Reason(errno: Int32(truncatingIfNeeded: error.code)) { return reason }
        }
        for error in chain where error.domain == NSCocoaErrorDomain {
            if let reason = Reason(cocoa: error.code) { return reason }
        }
        for error in chain where error.domain == NSOSStatusErrorDomain {
            if let reason = Reason(osStatus: error.code) { return reason }
        }
        return .other
    }

}


// MARK: - Synthesis

extension FinderItem.FileError {

    /// Builds the error that Foundation would have produced for `reason`, so that the system composes, and localizes, the message.
    ///
    /// This is the inverse of ``classify(_:)``.
    ///
    /// - Parameters:
    ///   - nested: The error to keep as the nested error. When `nil`, a POSIX error matching `reason` is used, if there is one.
    static func synthesize(_ reason: Reason, source: FinderItem, intent: Intent, nested: NSError?) -> NSError {
        func pick(_ reading: CocoaError.Code, _ writing: CocoaError.Code) -> CocoaError.Code {
            intent == .writing ? writing : reading
        }
        let unknown = pick(.fileReadUnknown, .fileWriteUnknown)

        let code: CocoaError.Code
        let posix: Int32?
        switch reason {
        case .noSuchFile:
            (code, posix) = (.fileNoSuchFile, ENOENT)
        case .noPermission:
            (code, posix) = (pick(.fileReadNoPermission, .fileWriteNoPermission), EACCES)
        case .fileExists:
            (code, posix) = (.fileWriteFileExists, EEXIST)
        case .directoryNotEmpty:
            (code, posix) = (unknown, ENOTEMPTY)
        case .outOfSpace:
            (code, posix) = (.fileWriteOutOfSpace, ENOSPC)
        case .readOnlyVolume:
            (code, posix) = (.fileWriteVolumeReadOnly, EROFS)
        case .invalidName:
            (code, posix) = (pick(.fileReadInvalidFileName, .fileWriteInvalidFileName), nil)
        case .isDirectory:
            (code, posix) = (unknown, EISDIR)
        case .notDirectory:
            (code, posix) = (unknown, ENOTDIR)
        case .busy:
            (code, posix) = (unknown, EBUSY)
        case .differentVolume:
            (code, posix) = (unknown, EXDEV)
        case .tooLarge:
            (code, posix) = (.fileReadTooLarge, EFBIG)
        case .corruptFile:
            (code, posix) = (.fileReadCorruptFile, nil)
        case .unsupportedScheme:
            (code, posix) = (pick(.fileReadUnsupportedScheme, .fileWriteUnsupportedScheme), nil)
        case .stringEncoding:
            (code, posix) = (pick(.fileReadInapplicableStringEncoding, .fileWriteInapplicableStringEncoding), nil)
        case .cancelled:
            (code, posix) = (.userCancelled, nil)
        default:
            (code, posix) = (unknown, nil)
        }

        var userInfo: [String : Any] = [
            NSURLErrorKey: source.url,
            NSFilePathErrorKey: source.path,
        ]
        if let nested {
            userInfo[NSUnderlyingErrorKey] = nested
        } else if let posix {
            userInfo[NSUnderlyingErrorKey] = NSError(domain: NSPOSIXErrorDomain, code: Int(posix))
        }
        return NSError(domain: NSCocoaErrorDomain, code: code.rawValue, userInfo: userInfo)
    }

    /// The item that the system blames in `error`, if the error names one.
    ///
    /// This is for operations that have no item of their own. Everywhere else the operation supplies the item.
    @usableFromInline
    static func failingItem(in error: any Error) -> FinderItem? {
        let userInfo = (error as NSError).userInfo
        if let url = userInfo[NSURLErrorKey] as? URL {
            return FinderItem(_url: url)
        }
        if let path = userInfo[NSFilePathErrorKey] as? String {
            return FinderItem(_url: URL(filePath: path))
        }
        return nil
    }

    /// Makes sure that the system's text for `error` can name the file.
    ///
    /// - A bare POSIX error is re-expressed the way Foundation reports it: as a Cocoa error that names the file, with the POSIX error nested.
    /// - A `CancellationError` is expressed as `NSUserCancelledError` in the same way.
    /// - A Cocoa file error that names no file, such as the one for undecodable text, is completed with `source`. Nothing else about it changes.
    /// - Other errors are returned as they are.
    static func normalize(_ error: any Error, source: FinderItem, intent: Intent) -> any Error {
        if error is CancellationError {
            return synthesize(.cancelled, source: source, intent: intent, nested: error as NSError)
        }

        let nsError: NSError
        if let errno = error as? Errno {
            nsError = NSError(domain: NSPOSIXErrorDomain, code: Int(errno.rawValue))
        } else {
            nsError = error as NSError
        }

        switch nsError.domain {
        case NSPOSIXErrorDomain:
            let reason = Reason(errno: Int32(truncatingIfNeeded: nsError.code)) ?? .other
            return synthesize(reason, source: source, intent: intent, nested: nsError)

        case NSCocoaErrorDomain where (0...1023).contains(nsError.code) && nsError.userInfo[NSURLErrorKey] == nil && nsError.userInfo[NSFilePathErrorKey] == nil:
            var userInfo = nsError.userInfo
            userInfo[NSURLErrorKey] = source.url
            userInfo[NSFilePathErrorKey] = source.path
            return NSError(domain: nsError.domain, code: nsError.code, userInfo: userInfo)

        default:
            return error
        }
    }

}
