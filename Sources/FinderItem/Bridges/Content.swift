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
    
#if canImport(GraphicsKit)
    /// Returns the image at the location, if exists.
    @available(*, deprecated, message: "Please use \"load(.image)\" instead.")
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
    ///
    /// - Tip: This function is async to present blocking.
    @inlinable
    nonisolated func setIcon(image: NSImage) async {
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
    func reveal() throws(FileError) {
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
    func open(configuration: NSWorkspace.OpenConfiguration) async throws {
        try await NSWorkspace.shared.open(url, configuration: configuration)
    }
    
    /// Opens the current file.
    @inlinable
    func open(configuration: NSWorkspace.OpenConfiguration? = nil) async throws {
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
