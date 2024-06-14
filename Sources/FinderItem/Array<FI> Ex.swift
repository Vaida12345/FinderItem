//
//  Array<FinderItem> Extensions.swift
//  The Stratum Module
//
//  Created by Vaida on 5/1/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif
import UniformTypeIdentifiers


// MARK: - Initialize / append elements
public extension Array where Element == FinderItem {
    
    /// Initialize with the providers of files and their ``FinderItem/children(range:)`` whose type is `option`.
    ///
    /// - Important: It requires `supportedContentTypes` to be only `[.fileURL]`.
    ///
    /// - Note: If you do not want to have the `providers` iterated, use the initializer instead.
    ///
    /// - Parameters:
    ///   - providers: The providers of items from which all of their children and themselves would be iterated to obtain items of the type `option`.
    @inlinable
    init(from providers: [NSItemProvider]) async throws {
        self.init()
        self.reserveCapacity(providers.count)
        for provider in providers {
            let item = try await FinderItem(from: provider)
            self.append(item)
        }
    }
    
    /// Returns the inputs with their children flatten for directories.
    @inlinable
    init(flatten: [FinderItem]) throws {
        var results: [FinderItem] = []
        results.reserveCapacity(flatten.count)
        
        for flatten_ in flatten {
            if flatten_.isDirectory {
                try results.append(contentsOf: flatten_.children(range: .enumeration))
            } else {
                results.append(flatten_)
            }
        }
        
        self = results
    }
}


// MARK: - Extension on array
public extension Array where Element == FinderItem {
    
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
    /// Reveals the files in finder.
    @inlinable
    func revealInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting(self.map(\.url))
    }
#endif
    
}


