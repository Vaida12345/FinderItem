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
#if !os(tvOS) && !os(watchOS)
import QuickLookThumbnailing
#endif
import GraphicsKit


public extension FinderItem {
    
    /// Loads the data to the expected `type`.
    ///
    /// This is a variant of ``load(_:)-163we``
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it would throw ``FinderItem/LoadError/encounteredNil``.
    func load<T, E>(_ type: FinderItem.AsyncLoadableContent<T, E>) async throws(E) -> T where E: Error {
        try await type.contentLoader(self)
    }
    
    /// Loads the data to the expected `type`.
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it would throw ``FinderItem/LoadError/encounteredNil``.
    ///
    /// ## Topics
    ///
    /// ### The Loading Calls
    ///
    /// These methods also provides the way to load the content.
    ///
    /// - ``FinderItem/load(_:)-9a4yw``
    /// - ``FinderItem/load(_:format:)``
    ///
    ///
    /// ### The Contents
    ///
    /// - ``FinderItem/LoadableContent/data``
    /// - ``FinderItem/LoadableContent/resourceBytes``
    /// - ``FinderItem/LoadableContent/lines``
    ///
    /// ### The Media
    ///
    /// - ``FinderItem/LoadableContent/image``
    /// - ``FinderItem/LoadableContent/icon(size:)``
    /// - ``FinderItem/AsyncLoadableContent/preview(size:)``
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
    
    /// One of the possible errors thrown by ``FinderItem/load(_:)-163we``, ``FinderItem/load(_:)-9a4yw``.
    enum LoadError: _GenericError {
        
        /// The API returned `nil`.
        ///
        /// No further information was given by the API.
        case encounteredNil(name: String, type: String)
        
        public var title: String {
            switch self {
            case let .encounteredNil(name, type):
                "Load \(name) as \(type) resulted in failure"
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
    /// You do not call this structure directly, you should use ``FinderItem/load(_:)-163we``.
    public struct LoadableContent<Result, Failure> where Failure: Error {
        
        fileprivate let contentLoader: (FinderItem) throws(Failure) -> Result
        
        
        fileprivate init(contentLoader: @escaping (_ source: FinderItem) throws(Failure) -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
    
    /// An asynchronous loadable property that constrains the value.
    ///
    /// You do not call this structure directly, you should use ``FinderItem/load(_:)-9a4yw``.
    public struct AsyncLoadableContent<Result, Failure> where Failure: Error {
        
        fileprivate let contentLoader: (FinderItem) async throws(Failure) -> Result
        
        
        fileprivate init(contentLoader: @escaping (_ source: FinderItem) async throws(Failure) -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
}


public extension FinderItem.LoadableContent {
    
    /// Returns the image at the location, if exists.
    static var image: FinderItem.LoadableContent<NativeImage, any Error> {
        .init { (source: FinderItem) throws -> NativeImage in
            do {
                let data = try Data(at: source)
                if let image = NativeImage(data: data) {
                    return image
                } else {
                    throw FinderItem.LoadError.encounteredNil(name: source.name, type: "image")
                }
            } catch {
                if let error = try? FinderItem.FileError.parse(error) {
                    throw error
                } else {
                    throw error
                }
            }
        }
    }
    
    /// Returns the image at the location, if exists.
    static var cgImage: FinderItem.LoadableContent<CGImage, any Error> {
        .init { (source: FinderItem) throws -> CGImage in
            try self.image.contentLoader(source).cgImage!
        }
    }
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Returns the icon at the location.
    ///
    /// The resulting image is scaled down to the required `size`.
    ///
    /// - Parameters:
    ///   - size: The size of the image.
    ///
    /// - Returns: If the file does not exist, or no representations larger than `size`, returns nil.
    static func icon(size: CGSize? = nil) -> FinderItem.LoadableContent<NativeImage, any Error> {
        .init { (source: FinderItem) throws -> NativeImage in
            guard source.exists else { throw FinderItem.FileError(code: .cannotRead(reason: .noSuchFile), source: source) }
            let icons = NSWorkspace.shared.icon(forFile: source.path)
            
            guard let size else { return icons }
            
            if let first = icons.representations.first(where: { CGFloat($0.pixelsHigh) >= size.height && CGFloat($0.pixelsWide) >= size.width }),
               let image = first.cgImage(forProposedRect: nil, context: nil, hints: nil),
               let scaled = image.resized(to: image.size.aspectRatio(.fit, in: size)) {
                return NativeImage(cgImage: scaled)
            } else {
                throw FinderItem.LoadError.encounteredNil(name: source.name, type: "icon")
            }
        }
    }
#endif
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



public extension FinderItem.AsyncLoadableContent {
    
#if !os(tvOS) && !os(watchOS)
    private static func generateImage(type: QLThumbnailGenerator.Request.RepresentationTypes, url: URL, size: CGSize) async throws -> (NativeImage, QLThumbnailRepresentation.RepresentationType) {
        let result = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: .init(fileAt: url, size: size, scale: 1, representationTypes: type))
        
#if os(macOS)
        return (result.nsImage, result.type)
#elseif os(iOS) || os(visionOS)
        return (result.uiImage, result.type)
#endif
    }
    
    /// Generate the preview image for the given source.
    ///
    /// - Parameters:
    ///   - size: The size of the image.
    ///
    /// - Returns: If the file does not exist, or no representations larger than `size`, returns nil.
    static func preview(size: CGSize) -> FinderItem.AsyncLoadableContent<NativeImage, any Error> {
        .init { source in
            guard source.exists else { throw FinderItem.FileError(code: .cannotRead(reason: .noSuchFile), source: source) }
            do {
                return try await generateImage(type: .thumbnail, url: source.url, size: size).0
            } catch {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
                do {
                    return try source.load(.icon(size: size))
                } catch {}
#endif
                return try await generateImage(type: .icon, url: source.url, size: size).0
            }
        }
    }
#endif
    
}
