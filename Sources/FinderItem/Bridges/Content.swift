//
//  FinderItem + Read & Write Contents.swift
//  The FinderItem Module
//
//  Created by Vaida on 5/1/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//


#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#else
import Foundation
#endif
#if canImport(GraphicsKit)
import GraphicsKit
#endif

#if !os(tvOS) && !os(watchOS)
import QuickLookThumbnailing
#endif


public extension FinderItem {
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    
    /// Returns the icon at the location, if exists.
    ///
    /// The return value is `nil` if the files doesn't exist, or, there is no tiff representation behind.
    func icon(size: CGSize? = nil) -> NSImage? {
        guard self.exists else { return nil }
        if let size {
            let scale: CGFloat = 2
            if let icon = self.icon(),
               let first = icon.representations.first(where: { CGFloat($0.pixelsHigh) >= size.height * scale && CGFloat($0.pixelsWide) >= size.width * scale }),
               let image = first.cgImage(forProposedRect: nil, context: nil, hints: nil),
               let scaled = image.resized(to: image.size.aspectRatio(.fit, in: size.scaled(by: scale))) {
                return NativeImage(cgImage: scaled)
            } else {
                return nil
            }
        } else {
            return NSWorkspace.shared.icon(forFile: self.path)
        }
        
    }
#endif
    
#if canImport(GraphicsKit)
    /// Returns the image at the location, if exists.
    @inlinable
    func image() -> NativeImage? {
        NativeImage(at: self.url)
    }
#endif
    
    /// Returns the itemProvider at the location, if exists.
    @inlinable
    func itemProvider() -> NSItemProvider? {
        NSItemProvider(contentsOf: self.url)
    }
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Sets an image as icon.
    ///
    /// - Parameters:
    ///   - image: The image indicating the new icon for the item.
    @inlinable
    func setIcon(image: NSImage) {
        guard self.exists else { return }
        NSWorkspace.shared.setIcon(image, forFile: self.path, options: .init())
    }
    
    /// Reveals the current file in finder.
    @MainActor @available(*, deprecated, renamed: "reveal")
    @inlinable
    func revealInFinder() {
        try? self.reveal()
    }
#endif
    
#if (canImport(AppKit) && !targetEnvironment(macCatalyst)) || (canImport(UIKit) && !os(watchOS))
    /// Reveals the current file in finder.
    ///
    /// - Warning: For bookmarked or user selected files, you might need to consider the security scope for both macOS and iOS.
    @MainActor @inlinable
    func reveal() throws {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        guard self.exists else { throw FileError(code: .cannotRead(reason: .noSuchFile), source: self) }
        NSWorkspace.shared.activateFileViewerSelecting([self.url])
#else
        guard self.exists else { throw FileError(code: .cannotRead(reason: .noSuchFile), source: self) }
        UIApplication.shared.open(self.url)
#endif
    }
#endif
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Opens the current file.
    @inlinable
    func open(configuration: NSWorkspace.OpenConfiguration? = nil) async throws {
        if let configuration {
            try await NSWorkspace.shared.open(url, configuration: configuration)
            return
        } else {
            if self.extension == "app" {
                try await NSWorkspace.shared.openApplication(at: self.url, configuration: .init())
                return
            } else if self.isDirectory {
                if self.extension == "xcodeproj" {
                    NSWorkspace.shared.open([self.url], withAppBundleIdentifier: "com.apple.dt.Xcode", options: .default, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
                    return
                }
            }
            
            try await self.open(configuration: .init())
        }
    }
#endif
    
#if !os(tvOS) && !os(watchOS)
    private func generateImage(type: QLThumbnailGenerator.Request.RepresentationTypes, url: URL, size: CGSize, scale: CGFloat = 2) async throws -> (NativeImage, QLThumbnailRepresentation.RepresentationType) {
        let result = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: .init(fileAt: url, size: size, scale: scale, representationTypes: type))
        
#if os(macOS)
        return (result.nsImage, result.type)
#elseif os(iOS) || os(visionOS)
        return (result.uiImage, result.type)
#endif
    }
    
    /// Generate the preview image for the given `FinderItem`.
    ///
    /// - Note: The pixel size of image is `size` \* `scale`.
    func preview(size: CGSize, scale: CGFloat = 2) async throws -> NativeImage {
        do {
            return try await generateImage(type: .thumbnail, url: url, size: size, scale: scale).0
        } catch {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
            if let icon = self.icon(size: size) {
                return icon
            }
#endif
            return try await generateImage(type: .icon, url: url, size: size, scale: scale).0
        }
    }
#endif
    
}


public extension FileWrapper {
    
    @inlinable
    convenience init(at source: FinderItem) throws {
        try self.init(url: source.url)
    }
    
}


public extension NSItemProvider {
    
    @inlinable
    convenience init?(at source: FinderItem) {
        self.init(contentsOf: source.url)
    }
    
}


#if canImport(TabularData)
import TabularData

public extension DataFrame {
    
    /// Writes the frame in form of csv to `destination`.
    ///
    /// - Parameters:
    ///   - destination: The destination of csv.
    @inlinable
    func write(to destination: FinderItem) throws {
        try self.writeCSV(to: destination.url)
    }
    
    /// Initialize with the contents at the specified `FinderItem`.
    ///
    /// - Parameters:
    ///   - source: The `FinderItem` representing the location of the csv file.
    ///   - columns: An array of column names; Set to nil to use every column in the CSV file.
    ///   - rows: A range of indices; Set to nil to use every row in the CSV file.
    ///   - types: A dictionary of column names and their CSV types. The data frame infers the types for column names that aren’t in the dictionary.
    ///   - options: The options that tell the data frame how to read the CSV file.
    @inlinable
    init(at source: FinderItem, columns: [String]? = nil, rows: Range<Int>? = nil, types: [String : CSVType] = [:], options: CSVReadingOptions = .init()) throws {
        let data = try Data(at: source)
        try self.init(csvData: data, columns: columns, rows: rows, types: types, options: options)
    }
    
}
#endif


public extension String {
    
    /// Writes the string to `destination` using the given `encoding`.
    @inlinable
    func write(to destination: FinderItem, encoding: Encoding = .utf8) throws {
        try self.write(to: destination.url, atomically: true, encoding: encoding)
    }
    
    /// Initialize with the content on disk
    @inlinable
    init(at source: FinderItem, encoding: Encoding = .utf8) throws {
        try self.init(contentsOf: source.url, encoding: encoding)
    }
    
}
