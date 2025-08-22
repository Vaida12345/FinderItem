//
//  Open.swift
//  FinderItem
//
//  Created by Vaida on 2025-08-22.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import CoreServices
import Essentials


public extension FinderItem {
    
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
    @available(*, deprecated, renamed: "reveal")
    @MainActor
    @inlinable
    func revealInFinder() async throws {
        try await self.reveal()
    }
    
    /// Opens an item for a URL in the default manner in its preferred app.
    ///
    /// This function returns after the app is opened.
    @inlinable
    func open() async throws(LaunchServiceError) {
        let status = LSOpenCFURLRef(self.url as CFURL, nil)
        guard status == noErr else { throw LaunchServiceError(rawValue: status) ?? .unknown }
    }
    
    /// Reveals the current file in finder.
    ///
    /// - Warning: For bookmarked or user selected files, you might need to consider the security scope for macOS.
    @inlinable
    func reveal() async throws(FileError) {
        guard self.exists else { throw FileError(code: .cannotRead(reason: .noSuchFile), source: self) }
        NSWorkspace.shared.activateFileViewerSelecting([self.url])
    }
    
}


/// A wrapper to `LaunchService` error codes.
public enum LaunchServiceError: OSStatus, LocalizableError, CaseIterable {
    
    /// i386 is no longer supported
    case no32BitEnvironment = -10386
    
    /// malformed internet locator file
    case malformedLoc = -10400
    
    /// The app cannot be run when inside a Trash folder
    case appInTrash = -10660
    
    /// No compatible executable was found
    case executableIncorrectFormat = -10661
    
    /// An item attribute value could not be found with the specified name
    case attributeNotFound = -10662
    
    /// The attribute is not settable
    case attributeNotSettable = -10663
    
    /// The app is incompatible with the current OS
    case incompatibleApplicationVersion = -10664
    
    /// PowerPC apps are no longer supported
    case noRosettaEnvironment = -10665
    
    /// Objective-C garbage collection is no longer supported
    case garbageCollectionUnsupported = -10666
    
    /// Unexpected internal error
    case unknown = -10810
    
    /// Item needs to be an application, but is not
    case notAnApplication = -10811
    
    /// Data of the desired type is not available (for example, there is no kind string).
    case dataUnavailable = -10813
    
    /// No app in the Launch Services database matches the input criteria. (E.g. no application claims the file)
    case applicationNotFound
    
    /// Don't know anything about the type of the item
    case unknownType = -10815
    
    /// A launch of the app is already in progress. (E.g. launching an already launching application)
    case launchInProgress = -10818
    
    /// One or more documents are of types (and/or one or more URLs are of schemes) not supported by the target application (sandboxed callers only)
    case appDoesNotClaimType = -10820
    
    /// The server process (registration and recent items) is not available
    case serverCommunication
    
    /// The extension visibility on this item cannot be changed
    case cannotSetInfo = -10822
    
    /// The item contains no registration info
    case noRegistrationInfo = -10824
    
    /// The app cannot run on the current OS version
    case incompatibleSystemVersion = -10825
    
    /// User doesn't have permission to launch the app (managed networks)
    case noLaunchPermission = -10826
    
    /// The executable is missing
    case noExecutable = -10827
    
    /// The Classic environment was required but is not available
    case noClassicEnvironment = -10828
    
    /// The app cannot run simultaneously in two different sessions
    case multipleSessionsNotSupported = -10829
    
    
    public var messageResource: LocalizedStringResource {
        switch self {
        case .no32BitEnvironment: "i386 is no longer supported"
        case .malformedLoc: "malformed internet locator file"
        case .appInTrash: "The app cannot be run when inside a Trash folder"
        case .executableIncorrectFormat: "No compatible executable was found"
        case .attributeNotFound: "An item attribute value could not be found with the specified name"
        case .attributeNotSettable: "The attribute is not settable"
        case .incompatibleApplicationVersion: "The app is incompatible with the current OS"
        case .noRosettaEnvironment: "PowerPC apps are no longer supported"
        case .garbageCollectionUnsupported: "Objective-C garbage collection is no longer supported"
        case .unknown: "Unexpected internal error"
        case .notAnApplication: "Item needs to be an application, but is not"
        case .dataUnavailable: "Data of the desired type is not available (for example, there is no kind string)."
        case .applicationNotFound: "No app in the Launch Services database matches the input criteria. (E.g. no application claims the file)"
        case .unknownType: "Don't know anything about the type of the item"
        case .launchInProgress: "A launch of the app is already in progress. (E.g. launching an already launching application)"
        case .appDoesNotClaimType: "One or more documents are of types (and/or one or more URLs are of schemes) not supported by the target application (sandboxed callers only)"
        case .serverCommunication: "The server process (registration and recent items) is not available"
        case .cannotSetInfo: "The extension visibility on this item cannot be changed"
        case .noRegistrationInfo: "The item contains no registration info"
        case .incompatibleSystemVersion: "The app cannot run on the current OS version"
        case .noLaunchPermission: "User doesn't have permission to launch the app (managed networks)"
        case .noExecutable: "The executable is missing"
        case .noClassicEnvironment: "The Classic environment was required but is not available"
        case .multipleSessionsNotSupported: "The app cannot run simultaneously in two different sessions"
        }
    }
    
}
#endif
