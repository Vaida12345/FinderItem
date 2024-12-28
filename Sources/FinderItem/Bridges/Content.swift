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


public extension FinderItem {
    
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
    /// - Note: The work is dispatched to a shared working thread and returns immediately. This ensures it is non-blocking and the underlying function is called on one thread at any given time, which is required.
    func setIcon(image: NSImage) {
        guard self.exists else { return }
        let work = DispatchWorkItem {
            NSWorkspace.shared.setIcon(image, forFile: self.path, options: .init())
        }
        FinderItem.workingThread.async(execute: work)
    }
    
    private static let workingThread = DispatchQueue(label: "FinderItem.DispatchWorkingThread")
    
    /// Reveals the current file in finder.
    @MainActor @available(*, deprecated, renamed: "reveal")
    @inlinable
    func revealInFinder() {
        try? self.reveal()
    }
    
    /// Opens the current file.
    ///
    /// - Parameters:
    ///   - configuration: The options that indicate how you want to open the URL.
    ///   - completionHandler: The completion handler block to call asynchronously with the results. AppKit executes the completion handler on a concurrent queue.
    @inlinable
    func open(configuration: NSWorkspace.OpenConfiguration = NSWorkspace.OpenConfiguration(), completionHandler: ((NSRunningApplication?, (any Error)?) -> Void)? = nil) {
        if self.extension == "app" {
            NSWorkspace.shared.openApplication(at: self.url, configuration: configuration, completionHandler: completionHandler)
        } else if self.isDirectory,
                  self.extension == "xcodeproj",
                  let appURL = Bundle(identifier: "com.apple.dt.Xcode")?.bundleURL {
            NSWorkspace.shared.open([self.url], withApplicationAt: appURL, configuration: configuration, completionHandler: completionHandler)
        } else {
            NSWorkspace.shared.open(self.url, configuration: configuration, completionHandler: completionHandler)
        }
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
