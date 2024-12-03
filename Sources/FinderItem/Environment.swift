//
//  FinderItem + Environment.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/5/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


public extension FinderItem {
    
    /// The directory for which are required but not visible for users.
    ///
    /// - Important: Stores app-created files only.
    ///
    /// - Warning: Contents are persisted and included in backups.
    ///
    /// - Note: Disk space used is reported in the storage settings.
    ///
    /// - Note: Examples include data files, configuration files, templates.
    static var applicationSupportDirectory: FinderItem {
        get throws(FileError) {
            let item = FinderItem(_url: .homeDirectory.appending(path: "Library/Application Support/", directoryHint: .isDirectory))
            if !item.exists { try item.makeDirectory() }
            return item
        }
    }
    
    /// The bundle directory for the current executable.
    ///
    /// - Important: The contents of the files are read-only.
    ///
    /// - Note: To access files in the app bundle, use `bundleDirectory.with(subPath: "Contents")`.
    ///
    /// - Note: use ``bundleItem(forResource:withExtension:in:)`` to access a file in the app bundle (files directly in the path).
    static var bundleDirectory: FinderItem {
        FinderItem(_url: Bundle.main.bundleURL)
    }
    
    /// The directory for which can be re-created by the app.
    ///
    /// - Warning: The system may delete the Caches directory to free up disk space.
    ///
    /// - Note: Contents are **not** included in backups.
    ///
    /// - Note: Disk space used is **not** reported in the storage settings.
    ///
    /// - Note: Examples include database cache files and downloadable content.
    static var cachesDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Library/Caches/", directoryHint: .isDirectory))
    }
    
    /// The working directory of the current process. Calling this property will issue a `getcwd` syscall.
    static var currentDirectory: FinderItem {
        FinderItem(_url: .currentDirectory())
    }
    
#if os(macOS)
    /// The desktop directory for the current user.
    ///
    /// - Important: This item is only valid to be used in Command Line Tools or Swift Packages.
    static var desktopDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Desktop/", directoryHint: .isDirectory))
    }
#endif
    
    /// The directory for which are visible to the user on iOS.
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
    static var documentsDirectory: FinderItem {
        FinderItem(_url: .documentsDirectory)
    }
    
    /// The downloads directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    static var downloadsDirectory: FinderItem {
        FinderItem(_url: .downloadsDirectory)
    }
    
    /// Creates and returns a temporary directory.
    static var itemReplacementDirectory: FinderItem {
        get throws {
            let itemReplacementDirectory = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: URL(fileURLWithPath: NSHomeDirectory()), create: true)
            return FinderItem(_url: itemReplacementDirectory)
        }
    }
    
    /// The home directory for the current app.
    ///
    /// - Important: In apps, it is recommended to use `documents` instead.
    static var homeDirectory: FinderItem {
        FinderItem(_url: URL.homeDirectory)
    }
    
    /// The library directory for the current app.
    static var libraryDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Library/", directoryHint: .isDirectory))
    }
    
    /// The logs directory for the current app.
    static var logsDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Library/Logs/", directoryHint: .isDirectory))
    }
    
    /// The movies directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    static var moviesDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Movies/", directoryHint: .isDirectory))
    }
    
    /// The music directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    static var musicDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Music/", directoryHint: .isDirectory))
    }
    
    /// The pictures directory for the current user.
    ///
    /// - Important: You need to set the appropriate file access permission in App Sandbox.
    static var picturesDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Pictures/", directoryHint: .isDirectory))
    }
    
    /// The preferences directory for the current app.
    ///
    /// The values stored in `@AppStorage` can be found at *bundle identifier*.plist
    static var preferencesDirectory: FinderItem {
        FinderItem(_url: .homeDirectory.appending(path: "Library/Preferences/", directoryHint: .isDirectory))
    }
    
    /// The directory for which are temporarily.
    ///
    /// - Warning: Remember to delete the contents when no longer needed to free up space.
    ///
    /// - Experiment: Contents are removed when the device reboots.
    ///
    /// - Note: Contents are **not** included in backups.
    ///
    /// - Note: Disk space used is **not** reported in the storage settings.
    static var temporaryDirectory: FinderItem {
        FinderItem(_url: FileManager.default.temporaryDirectory)
    }
    
}
