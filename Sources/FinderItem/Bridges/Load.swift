//
//  FinderItem + Loading.swift
//  The FinderItem Module
//
//  Created by Vaida on 2024/3/18.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif
import Essentials


public extension FinderItem {
    
    /// Loads the data to the expected `type`.
    ///
    /// You can also define your own keys that can be loaded using this method, see ``AsyncLoadableContent``.
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it should throw [corruptFile](``FileError/Code/ReadFailureReason/corruptFile``).
    @inlinable
    func load<T, E>(_ type: FinderItem.AsyncLoadableContent<T, E>) async throws(E) -> T where E: Error {
        try await type.contentLoader(self)
    }
    
    /// Loads the data to the expected `type`.
    ///
    /// You can also define your own keys that can be loaded using this method, see ``LoadableContent``.
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it should throw [corruptFile](``FileError/Code/ReadFailureReason/corruptFile``).
    ///
    /// ## Topics
    ///
    /// ### The Loading Calls
    ///
    /// These methods also provides the way to load the content.
    ///
    /// - ``FinderItem/load(_:)-1vmco``
    /// - ``FinderItem/load(_:format:)``
    ///
    ///
    /// ### The Contents
    ///
    /// - ``FinderItem/LoadableContent/data``
    /// - ``FinderItem/AsyncLoadableContent/resourceBytes``
    /// - ``FinderItem/AsyncLoadableContent/lines``
    /// - ``FinderItem/LoadableContent/string(encoding:)``
    ///
    /// ### The Representation
    ///
    /// - ``FinderItem/LoadableContent/fileWrapper(options:)``
    ///
    ///
    /// ### The Structures
    ///
    /// You should not interact with these structures directly, only the static properties and methods listed above.
    ///
    /// - ``FinderItem/LoadableContent``
    /// - ``FinderItem/AsyncLoadableContent``
    @inlinable
    func load<T, E>(_ type: FinderItem.LoadableContent<T, E>) throws(E) -> T where E: Error {
        try type.contentLoader(self)
    }
    
    /// Decodes the data to the expected `type`.
    ///
    /// - Parameters:
    ///   - type: The type the file represents.
    ///   - format: The decoder to be used.
    ///
    /// - Returns: The contents decoded.
    @inlinable
    func load<T>(_ type: T.Type, format: Data.CodingFormat) throws -> T where T: Decodable {
        try self.load(.data).decoded(type: T.self, format: format)
    }
    
}


extension FinderItem {
    
    /// An loadable property that constrains the value.
    ///
    /// You can extend this struct to define more contents that `FinderItem` can ``FinderItem/load(_:)-1vmco``.
    ///
    /// ```swift
    /// extension FinderItem.LoadableContent {
    ///     public static var container: FinderItem.LoadableContent<MIDIContainer, any Error> {
    ///         .init { source in
    ///             try MIDIContainer(at: source)
    ///         }
    ///     }
    /// }
    /// ```
    public struct LoadableContent<Result, Failure> where Failure: Error {
        
        public let contentLoader: (FinderItem) throws(Failure) -> Result
        
        
        @inlinable
        public init(contentLoader: @escaping (_ source: FinderItem) throws(Failure) -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
    
    /// An asynchronous loadable property that constrains the value.
    ///
    /// You can extend this struct to define more contents that `FinderItem` can ``FinderItem/load(_:)-1vmco``.
    ///
    /// ```swift
    /// extension FinderItem.AsyncLoadableContent {
    ///     public static var container: FinderItem.AsyncLoadableContent<MIDIContainer, any Error> {
    ///         .init { source in
    ///             try await MIDIContainer(at: source)
    ///         }
    ///     }
    /// }
    /// ```
    public struct AsyncLoadableContent<Result, Failure> where Failure: Error {
        
        public let contentLoader: (FinderItem) async throws(Failure) -> Result
        
        
        @inlinable
        public init(contentLoader: @escaping (_ source: FinderItem) async throws(Failure) -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
}


public extension FinderItem.LoadableContent {
    
    /// Creates a file wrapper instance whose kind is determined by the type of file-system node located by the URL.
    ///
    /// - Parameters:
    ///   - options: Option flags for reading the node located at url.
    @inlinable
    static func fileWrapper(options: FileWrapper.ReadingOptions = []) -> FinderItem.LoadableContent<FileWrapper, any Error> {
        .init { source in
            try FileWrapper(url: source.url, options: options)
        }
    }
    
}


#if canImport(AVFoundation)
import AVFoundation

public extension FinderItem.AsyncLoadableContent {
    
    /// Loads the `AVAsset` at the source.
    @inlinable
    static var avAsset: FinderItem.AsyncLoadableContent<AVURLAsset, any Error> {
        .init { source in
            let asset = AVURLAsset(url: source.url)
            guard try await asset.load(.isReadable) else { throw AVAssetLoadError.notReadable(name: source.name) }
            return asset
        }
    }
    
    
    enum AVAssetLoadError: GenericError {
        case notReadable(name: String)
        
        @inlinable
        public var message: String {
            switch self {
            case .notReadable(let name):
                "The media \(name) is not readable."
            }
        }
        
    }
    
}
#endif


public extension FinderItem.LoadableContent {
    
    /// Loads the data at the source.
    @inlinable
    static var data: FinderItem.LoadableContent<Data, any Error> {
        .init { source in
            try Data(contentsOf: source.url)
        }
    }
    
}

public extension FinderItem.LoadableContent {
    
    /// Loads the string at the source.
    @inlinable
    static func string(encoding: String.Encoding = .utf8) -> FinderItem.LoadableContent<String, any Error> {
        .init { source in
            try String(at: source, encoding: encoding)
        }
    }
    
}


public extension FinderItem.AsyncLoadableContent {
    
    /// Loads the data at source as async bytes.
    @inlinable
    static var resourceBytes: FinderItem.AsyncLoadableContent<URL.AsyncBytes, Never> {
        .init { source in
            source.url.resourceBytes
        }
    }
    
    /// Loads the data at source as async lines.
    @inlinable
    static var lines: FinderItem.AsyncLoadableContent<AsyncLineSequence<URL.AsyncBytes>, Never> {
        .init { source in
            source.url.lines
        }
    }
    
}
