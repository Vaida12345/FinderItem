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
    /// For a list of available options, please refer to <doc:FinderItemLoad>.
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it would throw ``FinderItem/LoadError/encounteredNil``.
    ///
    /// - Bug: Currently always throws, will be fixed in Swift 6.0.
    func load<T>(_ type: FinderItem.AsyncLoadableContent<T>) async throws -> T {
        try await type.contentLoader(self)
    }
    
    /// Loads the data to the expected `type`.
    ///
    /// For a list of available options, please refer to <doc:FinderItemLoad>.
    ///
    /// - Returns: The return value would never be optional; if the original API chose to return `nil` on failure, it would throw ``FinderItem/LoadError/encounteredNil``.
    ///
    /// - Bug: Currently always throws, will be fixed in Swift 6.0.
    func load<T>(_ type: FinderItem.LoadableContent<T>) throws -> T {
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
        case encounteredNil
        
        public var title: String {
            "Load the given resource resulted in failure."
        }
        
        public var message: String {
            "The API returned `nil`, no further information was given."
        }
    }
    
}


extension FinderItem {
    
    /// An loadable property that constrains the value.
    ///
    /// You do not call this structure directly, you should use ``FinderItem/load(_:)-163we``. For a list of available options, please refer to <doc:FinderItemLoad>.
    public struct LoadableContent<Result> {
        
        fileprivate let contentLoader: (FinderItem) throws -> Result
        
        
        fileprivate init(contentLoader: @escaping (_ source: FinderItem) throws -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
    
    /// An asynchronous loadable property that constrains the value.
    ///
    /// You do not call this structure directly, you should use ``FinderItem/load(_:)-9a4yw``. For a list of available options, please refer to <doc:FinderItemLoad>.
    public struct AsyncLoadableContent<Result> {
        
        fileprivate let contentLoader: (FinderItem) async throws -> Result
        
        
        fileprivate init(contentLoader: @escaping (_ source: FinderItem) async throws -> Result) {
            self.contentLoader = contentLoader
        }
        
    }
    
}


public extension FinderItem.LoadableContent {
    
    /// Returns the image at the location, if exists.
    static var image: FinderItem.LoadableContent<NativeImage> {
        .init { source in
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
            if let image = NativeImage(contentsOf: source.url) {
                return image
            } else {
                throw FinderItem.LoadError.encounteredNil
            }
#elseif canImport(UIKit)
            let data = try Data(at: source)
            if let image = NativeImage(data: data) {
                return image
            } else {
                throw FinderItem.LoadError.encounteredNil
            }
#endif
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
    static func icon(size: CGSize? = nil) -> FinderItem.LoadableContent<NativeImage> {
        .init { source in
            guard source.exists else { throw FinderItem.LoadError.encounteredNil }
            let icons = NSWorkspace.shared.icon(forFile: source.path)
            
            guard let size else { return icons }
            
            if let first = icons.representations.first(where: { CGFloat($0.pixelsHigh) >= size.height && CGFloat($0.pixelsWide) >= size.width }),
               let image = first.cgImage(forProposedRect: nil, context: nil, hints: nil),
               let scaled = image.resized(to: image.size.aspectRatio(.fit, in: size)) {
                return NativeImage(cgImage: scaled)
            } else {
                throw FinderItem.LoadError.encounteredNil
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
    static func fileWrapper(options: FileWrapper.ReadingOptions = []) -> FinderItem.LoadableContent<FileWrapper> {
        .init { source in
            try FileWrapper(url: source.url, options: options)
        }
    }
    
}


#if canImport(AVFoundation)
import AVFoundation

public extension FinderItem.LoadableContent {
    
    /// Loads the `AVAsset` at the source.
    static var avasset: FinderItem.LoadableContent<AVURLAsset> {
        .init { source in
            AVURLAsset(url: source.url)
        }
    }
    
}
#endif


public extension FinderItem.LoadableContent {
    
    /// Loads the data at the source.
    static var data: FinderItem.LoadableContent<Data> {
        .init { source in
            try Data(contentsOf: source.url)
        }
    }
    
    /// Loads the data at source as async bytes.
    @available(macOS 12.0, *)
    static var resourceBytes: FinderItem.AsyncLoadableContent<URL.AsyncBytes> {
        .init { source in
            source.url.resourceBytes
        }
    }
    
    /// Loads the data at source as async lines.
    @available(macOS 12.0, *)
    static var lines: FinderItem.AsyncLoadableContent<AsyncLineSequence<URL.AsyncBytes>> {
        .init { source in
            source.url.lines
        }
    }
    
}

public extension FinderItem.LoadableContent {
    
    /// Loads the string at the source.
    static func string(encoding: String.Encoding = .utf8) -> FinderItem.LoadableContent<String> {
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
    static func preview(size: CGSize) -> FinderItem.AsyncLoadableContent<NativeImage> {
        .init { source in
            guard source.exists else { throw FinderItem.LoadError.encounteredNil }
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
