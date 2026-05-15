//
//  FinderItem + Environment.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/5/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import OSLog


public extension FinderItem {
    
    /// Locates and optionally creates the specified common directory in a domain.
    @inlinable
    static func url(for directory: FileManager.SearchPathDirectory, in mask: FileManager.SearchPathDomainMask = .userDomainMask, appropriateFor: FinderItem? = nil, create: Bool = true) throws(FileError) -> FinderItem {
        do {
            let url = try FileManager.default.url(for: directory, in: mask, appropriateFor: appropriateFor?.url, create: create)
            return FinderItem(_url: url)
        } catch {
            throw FileError.parse(error)
        }
    }
    
    /// The directory for which are required but not visible for users.
    ///
    /// For support files that your app needs to operate but that you don’t want to be openly visible.
    ///
    /// This directory stores data like configuration files, templates, and modified versions of default files from your bundle.
    ///
    /// - Note: For non-sandboxed macOS app, this returns `~/Library/Application Support`.
    @inlinable
    static var applicationSupportDirectory: FinderItem {
        FinderItem(_url: .applicationSupportDirectory)
    }
    
    /// The bundle directory for the current executable.
    ///
    /// - Important: The contents of the files are read-only.
    ///
    /// - Note: use ``bundleItem(forResource:withExtension:subdirectory:in:)`` to access a file in the app bundle.
    @inlinable
    static var bundleDirectory: FinderItem {
        FinderItem(_url: Bundle.main.bundleURL)
    }
    
    /// The directory for which can be re-created by the app.
    ///
    /// For files that persist longer than temporary files, but are still purgeable, use the caches directory. In the caches directory, store files the app doesn’t require to operate, but that improve performance, such as database cache files and transient, downloadable content.
    @inlinable
    static var cachesDirectory: FinderItem {
        FinderItem(_url: .cachesDirectory)
    }
    
    /// The working directory of the current process. Calling this property will issue a `getcwd` syscall.
    ///
    /// - SeeAlso: ``updateCurrentDirectory(to:)``.
    @inlinable
    static var currentDirectory: FinderItem {
        FinderItem(_url: .currentDirectory())
    }
    
    /// Changes the path of the current working directory to the specified path.
    ///
    /// - SeeAlso: ``currentDirectory``
    @inlinable
    static func updateCurrentDirectory(to item: FinderItem) throws(FileError) {
        let bool = FileManager.default.changeCurrentDirectoryPath(item.path)
        guard bool else { throw FileError(code: .unknown, source: item) }
    }
    
#if os(macOS)
    /// The desktop directory for the current user.
    @inlinable
    static var desktopDirectory: FinderItem {
        FinderItem(_url: .desktopDirectory)
    }
#endif
    
    /// The standard directory for document files.
    ///
    /// The system can make the contents of the `Documents` folder available for file sharing. Only store files in this folder that you want to expose to the person using your app.
    ///
    /// In iOS, this directory is within the app’s sandbox directory. In macOS, it’s within the app’s sandbox directory for sandboxed apps, or in the current user’s home directory (~/Documents) if the app isn’t sandboxed.
    ///
    /// - Experiment: The "Inbox" sub-directory name is unavailable.
    @inlinable
    static var documentsDirectory: FinderItem {
        FinderItem(_url: .documentsDirectory)
    }
    
    /// The downloads directory for the current user.
    ///
    /// In iOS, this directory is within the app’s sandbox directory. In macOS, it’s within the app’s sandbox directory for sandboxed apps, or in the current user’s home directory (~/Downloads) if the app isn’t sandboxed.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var downloadsDirectory: FinderItem {
        FinderItem(_url: .downloadsDirectory)
    }
    
    /// Creates and returns a temporary directory.
    ///
    /// This path is designed for atomic file replacement. You can use ``itemReplacementDirectory(in:)`` to specify the volume.
    ///
    /// - Note: You should remove a file when you are done with it.
    @inlinable
    static var itemReplacementDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .itemReplacementDirectory, appropriateFor: .documentsDirectory)
        }
    }
    
    /// Creates and returns a temporary directory.
    ///
    /// - Parameters:
    ///   - volume: The file path used to determine the location of the returned item. Only the volume of this parameter is used.
    ///
    /// - SeeAlso: ``replace(_:)``.
    @inlinable
    static func itemReplacementDirectory(in volume: FinderItem) throws(FileError) -> FinderItem {
        try FinderItem.url(for: .itemReplacementDirectory, appropriateFor: volume)
    }
    
    /// The home directory for the current app.
    ///
    /// - Important: In apps, it is recommended to use `documents` instead.
    @inlinable
    static var homeDirectory: FinderItem {
        FinderItem(_url: .homeDirectory)
    }
    
    /// The library directory for the current app.
    @inlinable
    static var libraryDirectory: FinderItem {
        FinderItem(_url: .libraryDirectory)
    }
    
    /// The logs directory for the current app.
    @inlinable
    static var logsDirectory: FinderItem {
        get throws {
            let item = FinderItem(_url: .libraryDirectory.appending(path: "Logs/", directoryHint: .isDirectory))
            if !item.exists { try item.makeDirectory() }
            return item
        }
    }
    
    /// The movies directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var moviesDirectory: FinderItem {
        FinderItem(_url: .moviesDirectory)
    }
    
    /// The music directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var musicDirectory: FinderItem {
        FinderItem(_url: .musicDirectory)
    }
    
    /// The pictures directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var picturesDirectory: FinderItem {
        FinderItem(_url: .picturesDirectory)
    }
    
    /// The preferences directory for the current app.
    ///
    /// The values stored in `@AppStorage` can be found at *bundle identifier*.plist
    @inlinable
    static var preferencesDirectory: FinderItem {
        get throws(FileError) {
            let item = FinderItem(_url: .libraryDirectory.appending(path: "Preferences/", directoryHint: .isDirectory))
            if !item.exists { try item.makeDirectory() }
            return item
        }
    }
    
    /// The trash directory.
    @inlinable
    static var trashDirectory: FinderItem {
        FinderItem(_url: .trashDirectory)
    }
    
    /// The directory for which are temporarily.
    ///
    /// The files are marked as discardable. Apps are recommended to delete such directory when the app closes. When using `AppDelegate` from `ViewCollection`, simply inherit from super class using `super.applicationWillTerminate()`.
    ///
    /// - Important: This directory is different across launches of the app.
    ///
    /// - Warning: Remember to delete the contents when no longer needed to free up space.
    static let temporaryDirectory: FinderItem = {
        let tempDir = FinderItem(_url: .temporaryDirectory).appending(path: UUID().uuidString, directoryHint: .isDirectory)
        do {
            try tempDir.makeDirectory()
        } catch {
            let logger = Logger(subsystem: "FinderItem", category: "temporaryDirectory")
            logger.error("Failed to create temporary directory[error=\(error.localizedDescription)]")
        }
        return tempDir
    }()
    
    /// The directory for which are temporarily.
    ///
    /// The exact location or unique ownership to the directory depends on the sandbox and OS.
    ///
    /// - Warning: Remember to delete the contents when no longer needed to free up space.
    ///
    /// - Experiment: Contents are removed when the computer reboots.
    ///
    /// - Note: When passing `general`, this is equivalent to calling ``itemReplacementDirectory``.
    @available(*, deprecated, renamed: "temporaryDirectory")
    @inlinable
    static func temporaryDirectory(intent: TemporaryDirectoryIntent) throws -> FinderItem {
        return .temporaryDirectory
    }
    
    /// The intent for creating a temporary directory.
    @available(*, deprecated)
    enum TemporaryDirectoryIntent: Equatable {
        
        /// The general purpose directory. Such directory may be shared for other functionalities.
        case general
        
        /// The files are marked as discardable. Apps are recommended to delete such directory when the app closes.
        ///
        /// - Tip: This directory is created on-demand, hence, when deleting such directory, use ``FinderItem/FinderItem/removeIfExists()``.
        ///
        /// - precondition: Bundle identifier exists.
        ///
        /// Using `AppDelegate` from `ViewCollection`, simply inherit from super class using `super.applicationWillTerminate()`
        case discardable
        
    }
    
}
