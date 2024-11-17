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
    /// This is a variant of ``load(_:)-97hgq``
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it would throw ``FinderItem/LoadError/encounteredNil(name:type:)``.
    func load<T, E>(_ type: FinderItem.AsyncLoadableContent<T, E>) async throws(E) -> T where E: Error {
        try await type.contentLoader(self)
    }
    
    /// Loads the data to the expected `type`.
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it would throw ``FinderItem/LoadError/encounteredNil(name:type:)``.
    ///
    /// ## Topics
    ///
    /// ### The Loading Calls
    ///
    /// These methods also provides the way to load the content.
    ///
    /// - ``FinderItem/load(_:)-824a``
    /// - ``FinderItem/load(_:format:)``
    ///
    ///
    /// ### The Contents
    ///
    /// - ``FinderItem/LoadableContent/data``
    /// - ``FinderItem/LoadableContent/resourceBytes``
    /// - ``FinderItem/LoadableContent/lines``
    /// - ``FinderItem/LoadableContent/string(encoding:)``
    ///
    /// ### The Representation
    ///
    /// - ``FinderItem/LoadableContent/fileWrapper(options:)``
    ///
    /// ### Errors
    ///
    /// - ``FinderItem/LoadError``
    ///
    ///
    /// ### The Structures
    ///
    /// You should not interact with these structures directly, only the static properties and methods listed above.
    ///
    /// - ``FinderItem/LoadableContent``
    /// - ``FinderItem/AsyncLoadableContent``
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
    func load<T>(_ type: T.Type, format: Data.CodingFormat) throws -> T where T: Decodable {
        try self.load(.data).decoded(type: T.self, format: format)
    }
    
    /// Generic error caused by loading contents.
    enum LoadError: GenericError {
        
        /// The API returned `nil`.
        ///
        /// No further information was given by the API.
        case encounteredNil(name: String, type: String)
        
        /// Is a directory instead of file
        case notAFile
        
        public var title: String {
            switch self {
            case let .encounteredNil(name, type):
                "Load file \(name) as \(type) resulted in failure"
            case .notAFile:
                "The given item is not a file"
            }
        }
        
        public var message: String {
            ""
        }
    }
    
}


extension FinderItem {
    
    /// An loadable property that constrains the value.
    ///
    /// You do not call this structure directly, you should use ``FinderItem/load(_:)-97hgq``.
    public struct LoadableContent<Result, Failure> where Failure: Error {
        
        public let contentLoader: (FinderItem) throws(Failure) -> Result
        
        
        public init(contentLoader: @escaping (_ source: FinderItem) throws(Failure) -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
    
    /// An asynchronous loadable property that constrains the value.
    ///
    /// You do not call this structure directly, you should use ``FinderItem/load(_:)-824a``.
    public struct AsyncLoadableContent<Result, Failure> where Failure: Error {
        
        public let contentLoader: (FinderItem) async throws(Failure) -> Result
        
        
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
    static var avAsset: FinderItem.AsyncLoadableContent<AVURLAsset?, Never> {
        .init { source in
            let asset = AVURLAsset(url: source.url)
            guard (try? await asset.load(.isReadable)) ?? false else { return nil }
            return asset
        }
    }
    
}
#endif


public extension FinderItem.LoadableContent {
    
    /// Loads the data at the source.
    static var data: FinderItem.LoadableContent<Data, any Error> {
        .init { source in
            try Data(contentsOf: source.url)
        }
    }
    
    /// Loads the data at source as async bytes.
    @available(macOS 12.0, *)
    static var resourceBytes: FinderItem.AsyncLoadableContent<URL.AsyncBytes, Never> {
        .init { source in
            source.url.resourceBytes
        }
    }
    
    /// Loads the data at source as async lines.
    @available(macOS 12.0, *)
    static var lines: FinderItem.AsyncLoadableContent<AsyncLineSequence<URL.AsyncBytes>, Never> {
        .init { source in
            source.url.lines
        }
    }
    
}

public extension FinderItem.LoadableContent {
    
    /// Loads the string at the source.
    static func string(encoding: String.Encoding = .utf8) -> FinderItem.LoadableContent<String, any Error> {
        .init { source in
            try String(at: source, encoding: encoding)
        }
    }
    
}
