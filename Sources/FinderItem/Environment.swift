//
//  FinderItem + Environment.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/5/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


public extension FinderItem {
    
    /// Locates and optionally creates the specified common directory in a domain.
    @inlinable
    static func url(for directory: FileManager.SearchPathDirectory, in mask: FileManager.SearchPathDomainMask = .userDomainMask, appropriateFor: FinderItem? = nil, create: Bool = true) throws(FileError) -> FinderItem {
        do {
            let url = try FileManager.default.url(for: directory, in: mask, appropriateFor: appropriateFor?.url, create: create)
            return FinderItem(_url: url)
        } catch {
            dump(error)
            throw FileError.parse(error)
        }
    }
    
    /// The directory for which are required but not visible for users.
    ///
    /// - Important: Stores app-created files only.
    ///
    /// - Warning: Contents are persisted and included in backups.
    ///
    /// - Note: Disk space used is reported in the storage settings.
    ///
    /// - Note: Examples include data files, configuration files, templates.
    @inlinable
    static var applicationSupportDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .applicationSupportDirectory)
        }
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
    ///
    /// - Warning: The system may delete the Caches directory to free up disk space.
    ///
    /// - Note: Contents are **not** included in backups.
    ///
    /// - Note: Disk space used is **not** reported in the storage settings.
    ///
    /// - Note: Examples include database cache files and downloadable content.
    @inlinable
    static var cachesDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .cachesDirectory)
        }
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
    ///
    /// - Important: This item is only valid to be used in Command Line Tools or Swift Packages on macOS.
    @inlinable
    static var desktopDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .desktopDirectory)
        }
    }
#endif
    
    /// The standard directory for document files.
    ///
    /// In iOS, this directory is within the app’s sandbox directory. In macOS, it’s within the app’s sandbox directory for sandboxed apps, or in the current user’s home directory (~/Documents) if the app isn’t sandboxed.
    ///
    /// - Important: Stores user-generated documents only.
    ///
    /// - Warning: Contents are persisted and included in backups.
    ///
    /// - Note: Disk space used is reported in the storage settings.
    ///
    /// - Note: Contents are visible in “Files” application and can be found via spotlight.
    ///
    /// - Experiment: The "Inbox" sub-directory name is unavailable.
    @inlinable
    static var documentsDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .documentDirectory)
        }
    }
    
    /// The downloads directory for the current user.
    ///
    /// In iOS, this directory is within the app’s sandbox directory. In macOS, it’s within the app’s sandbox directory for sandboxed apps, or in the current user’s home directory (~/Downloads) if the app isn’t sandboxed.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var downloadsDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .downloadsDirectory)
        }
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
        get throws(FileError) {
            try FinderItem.url(for: .libraryDirectory)
        }
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
        get throws(FileError) {
            try FinderItem.url(for: .moviesDirectory)
        }
    }
    
    /// The music directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var musicDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .musicDirectory)
        }
    }
    
    /// The pictures directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    @inlinable
    static var picturesDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .picturesDirectory)
        }
    }
    
    /// The preferences directory for the current app.
    ///
    /// The values stored in `@AppStorage` can be found at *bundle identifier*.plist
    @inlinable
    static var preferencesDirectory: FinderItem {
        FinderItem(_url: .libraryDirectory.appending(path: "Preferences/", directoryHint: .isDirectory))
    }
    
    /// The trash directory.
    @inlinable
    static var trashDirectory: FinderItem {
        get throws(FileError) {
            try FinderItem.url(for: .trashDirectory)
        }
    }
    
    /// The directory for which are temporarily.
    ///
    /// The files are marked as discardable. Apps are recommended to delete such directory when the app closes. When using `AppDelegate` from `ViewCollection`, simply inherit from super class using `super.applicationWillTerminate()`.
    ///
    /// - Important: This directory is different across launches of the app.
    ///
    /// - Warning: Remember to delete the contents when no longer needed to free up space.
    ///
    /// - Experiment: Contents are removed when the device reboots.
    ///
    /// - Note: Contents are **not** included in backups.
    ///
    /// - Note: Disk space used is **not** reported in the storage settings.
    static let temporaryDirectory: FinderItem = {
        let tempDir = FinderItem(_url: FileManager.default.temporaryDirectory).appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try? tempDir.makeDirectory()
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
        let directory = FinderItem(_url: FileManager.default.temporaryDirectory)
        switch intent {
        case .general:
            return directory
        case .discardable:
            if let identifier = Bundle.main.bundleIdentifier {
                let directory = directory.appending(path: "\(identifier).discardable", directoryHint: .isDirectory)
                try directory.makeDirectory()
                return directory
            } else {
                preconditionFailure("A bundle identifier cannot be identified. Hence the unique ownership of temporary directory cannot be determined.")
            }
        }
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
