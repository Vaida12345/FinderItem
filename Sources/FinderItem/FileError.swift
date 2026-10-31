//
//  FinderItem + Error.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/4/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import Essentials
import System
import DetailedDescription


extension FinderItem {
    
    /// A file operation error.
    ///
    /// A `FileError` pairs what the system reported, ``underlyingError``, with where it happened: ``source``, ``destination``, and ``intent``.
    /// Its ``message`` is the system's own text for that error. It is localized, and for most errors it names the file, so it needs no title.
    ///
    /// Use ``reason`` to determine the nature of the error.
    ///
    /// ```swift
    /// do {
    ///     try item.remove()
    /// } catch {
    ///     if error.reason == .noSuchFile {
    ///         ...
    ///     }
    /// }
    /// ```
    ///
    /// The ``reason`` is a best-effort classification. An error that is not recognized is ``Reason/other``, and is still described in full by ``message``, ``details``, and ``underlyingError``.
    ///
    /// > Tip:
    /// > To classify an error that did not come from this package, wrap it: `FinderItem.FileError(error, source: item).reason`.
    ///
    /// ## Topics
    /// ### Context
    /// - ``source``
    /// - ``destination``
    /// - ``intent``
    /// - ``Intent``
    ///
    /// ### Classification
    /// - ``reason``
    /// - ``Reason``
    ///
    /// ### Error Information
    /// - ``message``
    /// - ``details``
    /// - ``underlyingError``
    /// - ``errno``
    /// - ``recoverySuggestion``
    public struct FileError: GenericError, CustomNSError, Sendable {

        /// The item the operation was performed on.
        ///
        /// This is supplied by the operation, never inferred from the error. It is a copy: later changes to the original item, such as moving it, do not affect the error.
        public let source: FinderItem

        /// The other end of the operation, for operations such as copy and move.
        public let destination: FinderItem?

        /// What the operation was doing to the file system.
        public let intent: Intent

        /// What the system reported, as it was reported.
        ///
        /// Nothing is dropped: the `userInfo` and the nested errors are all still there. The only addition is the item, when the system left it out: some errors, such as the one for undecodable text, name no file, so `source` is added for the message to name it.
        public let underlyingError: any Error

        /// The nature of the error.
        ///
        /// This is derived from ``underlyingError``. Use it to branch on the error; use ``message`` to present it.
        ///
        /// ```swift
        /// if fileError.reason == .noSuchFile {
        ///     ...
        /// }
        /// ```
        public let reason: Reason


        /// What an operation was doing to the file system.
        ///
        /// The system words some errors differently for reading and for writing, such as "you don't have permission to view it" and "you don't have permission to save it". The intent selects the wording of those errors when an error is created from a ``Reason``, or from a bare POSIX error. Errors that the system words only one way, such as ``Reason/tooLarge``, read the same for either intent.
        public enum Intent: Sendable, Equatable, CaseIterable {

            /// The operation reads from the file system.
            case reading

            /// The operation changes the file system.
            case writing

        }


        // MARK: - Initializers

        /// Wraps an error reported by the system.
        ///
        /// This accepts any error: a `CocoaError`, a `POSIXError`, an `Errno`, a `URLError`, or one of your own. Nothing is lost, the original is kept as the ``underlyingError``. A bare POSIX error is reported the way Foundation reports it: as a Cocoa error that names the file, with the POSIX error nested.
        ///
        /// A `FileError` is returned as it is, so that wrapping a nested operation's error does not change where it happened.
        ///
        /// - Parameters:
        ///   - error: The error to wrap.
        ///   - source: The item the operation was performed on.
        ///   - destination: The other end of the operation, if there is one.
        ///   - intent: What the operation was doing. It only matters for bare POSIX errors.
        ///   - operation: The function that was running. It is shown in ``details``.
        public init(_ error: some Error, source: FinderItem, destination: FinderItem? = nil, intent: Intent) {
            if let existing = error as? FileError {
                self = existing
            } else {
                self.init(
                    resolving: Self.normalize(error, source: source, intent: intent),
                    source: source,
                    destination: destination,
                    intent: intent
                )
            }
        }

        /// Creates the error that the system would have reported for `reason`.
        ///
        /// Use this when your own check fails, rather than the system's. The system composes the message, so it is localized.
        ///
        /// ```swift
        /// guard item.exists else { throw FinderItem.FileError(.noSuchFile, source: item) }
        /// ```
        ///
        /// - Parameters:
        ///   - reason: The nature of the error.
        ///   - source: The item the operation was performed on.
        ///   - destination: The other end of the operation, if there is one.
        ///   - intent: What the operation was doing. It selects the wording of the message.
        ///   - operation: The function that was running. It is shown in ``details``.
        public init(_ reason: Reason, source: FinderItem, destination: FinderItem? = nil, intent: Intent) {
            self.init(
                resolving: Self.synthesize(reason, source: source, intent: intent, nested: nil),
                source: source,
                destination: destination,
                intent: intent
            )
        }

        private init(resolving underlyingError: any Error, source: FinderItem, destination: FinderItem?, intent: Intent) {
            self.source = FinderItem(_url: source.url)
            self.destination = destination.map { FinderItem(_url: $0.url) }
            self.intent = intent
            self.underlyingError = underlyingError
            self.reason = Self.classify(Self.chain(of: underlyingError))
        }

        /// Runs `body`, and reports whatever it throws as a `FileError`.
        ///
        /// The `body` is deliberately untyped: a closure literal does not infer a typed throw, so a typed parameter would force `() throws(FileError) in` on every caller.
        @inlinable
        internal static func wrapping<T>(
            source: FinderItem,
            destination: FinderItem? = nil,
            intent: Intent,
            _ body: () throws -> T
        ) throws(FileError) -> T {
            do {
                return try body()
            } catch {
                throw FileError(error, source: source, destination: destination, intent: intent)
            }
        }


        // MARK: - Error Information

        /// The system's description of the error.
        ///
        /// This is the text the system uses for the ``underlyingError``, so it is localized. For most errors it names the file; the system leaves the file out of a few, such as text-encoding errors, so use ``source`` when you need it. If the system gives no reason of its own, the nearest nested reason is appended, such as "Is a directory."
        ///
        /// Paths are in ``details``.
        public var message: String {
            let chain = Self.chain(of: underlyingError)
            guard let top = chain.first else { return String(describing: underlyingError) }

            var text = top.localizedDescription
            if top.localizedFailureReason == nil,
               let nested = chain.dropFirst().lazy.compactMap(\.localizedFailureReason).first(where: { !$0.isEmpty }),
               !text.contains(nested) {
                let isCJK = text.last == "。"
                text += (isCJK ? "" : " ") + nested
                if let last = nested.last, !last.isPunctuation {
                    text += isCJK ? "。" : "."
                }
            }
            return text
        }

        /// Everything about the error, for debugging.
        ///
        /// This is the operation, the reason, the intent, the items, and every error in the chain with its `userInfo`, drawn as a tree by DetailedDescription.
        /// It is attached to the `debugDescription`, and is not shown to users.
        ///
        /// ```
        /// copy(to:)
        ///  ├─reason: fileExists
        ///  ├─intent: writing
        ///  ├─source: "/tmp/a.txt"
        ///  ├─destination: "/tmp/b.txt"
        ///  ╰─NSCocoaErrorDomain 516
        ///    ├─description: "“a.txt” couldn’t be copied to “tmp” because an item with the same name already exists."
        ///    ├─NSFilePath: "/tmp/a.txt"
        ///    ╰─NSPOSIXErrorDomain 17
        ///      ╰─description: "The operation couldn’t be completed. File exists"
        /// ```
        public var details: String? {
            Details(error: self).detailedDescription
        }

        /// The POSIX error, if one is in the chain of ``underlyingError``.
        public var errno: Errno? {
            Self.chain(of: underlyingError)
                .first(where: { $0.domain == NSPOSIXErrorDomain })
                .map { Errno(rawValue: Int32(truncatingIfNeeded: $0.code)) }
        }

        /// The system's suggestion for recovering from the error, if it has one.
        public var recoverySuggestion: String? {
            Self.chain(of: underlyingError).first?.localizedRecoverySuggestion
        }


        // MARK: - Bridging

        public static var errorDomain: String {
            "FinderItem.FileError"
        }

        public var errorCode: Int {
            switch reason {
            case .noSuchFile: 1
            case .noPermission: 2
            case .fileExists: 3
            case .directoryNotEmpty: 4
            case .outOfSpace: 5
            case .readOnlyVolume: 6
            case .invalidName: 7
            case .isDirectory: 8
            case .notDirectory: 9
            case .busy: 10
            case .differentVolume: 11
            case .tooLarge: 12
            case .corruptFile: 13
            case .unsupportedScheme: 14
            case .stringEncoding: 15
            case .cancelled: 16
            default: 0
            }
        }

        public var errorUserInfo: [String : Any] {
            var userInfo: [String : Any] = [
                NSUnderlyingErrorKey: underlyingError,
                NSURLErrorKey: source.url,
                NSFilePathErrorKey: source.path,
            ]
            if let destination {
                userInfo["NSDestinationFilePath"] = destination.path
            }
            return userInfo
        }


        // MARK: - Equatable

        /// Two errors are equal when they are of the same ``reason`` for the same items.
        ///
        /// The ``underlyingError`` and the ``intent`` are not compared.
        public static func == (lhs: FileError, rhs: FileError) -> Bool {
            lhs.reason == rhs.reason && lhs.source == rhs.source && lhs.destination == rhs.destination
        }

    }

}


// MARK: - Details

extension FinderItem.FileError {

    /// Describes the error as a tree, the way DetailedDescription describes any structure.
    fileprivate struct Details: DetailedStringConvertible {

        let error: FinderItem.FileError

        func detailedDescription(using descriptor: DetailedDescription.Descriptor<Details>) -> any DescriptionBlockProtocol {
            descriptor.container("\(error.reason) (\(error.intent))") {
                descriptor.value("source", of: error.source.path)
                descriptor.optional("destination", of: error.destination?.path)
                chain(FinderItem.FileError.chain(of: error.underlyingError)[...], using: descriptor)
            }
        }

        /// The errors, outermost first, each one containing the next.
        @DetailedDescription.Builder
        private func chain(_ errors: ArraySlice<NSError>, using descriptor: DetailedDescription.Descriptor<Details>) -> any DescriptionBlockProtocol {
            if let current = errors.first {
                descriptor.container("\(current.domain) \(current.code)") {
                    descriptor.value("description", of: current.localizedDescription)
                    descriptor.forEach(current.userInfo.filter { $0.key != NSUnderlyingErrorKey && $0.key != "NSUserStringVariant" }.sorted { $0.key < $1.key }) { entry in
                        descriptor.value(entry.key, of: entry.value)
                    }
                    chain(errors.dropFirst(), using: descriptor)
                }
            }
        }

    }
    
}
