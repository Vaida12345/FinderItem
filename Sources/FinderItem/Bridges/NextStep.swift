//
//  NeXTStep Extensions.swift
//  The Stratum Module - Extended Functionalities
//
//  Created by Vaida on 1/7/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import UniformTypeIdentifiers

public extension NSItemProvider {
    
    /// Register the folder at `source`.
    @inlinable
    func registerFolder(at source: FinderItem) {
        self.registerFileRepresentation(for: .folder, openInPlace: true) { handler in
            handler(source.url, true, nil)
            return nil
        }
    }
    
    /// Creates a folder, performs `handler` on it, and register.
    @inlinable
    func registerFolder(name: String, _ handler: @escaping @Sendable (_ destination: FinderItem) throws -> Void) {
        self.registerFileRepresentation(for: .folder, openInPlace: true) { loadHandler in
            do {
                let item = try FinderItem.itemReplacementDirectory.appending(path: name)
                try item.makeDirectory()
                
                try handler(item)
                loadHandler(item.url, false, nil)
            } catch {
                loadHandler(nil, false, error)
            }
            
            return nil
        }
    }
    
    /// Registers an object that can be written to disk.
    @inlinable
    func registerItem(name: String, type: UTType, _ handler: @escaping @Sendable (_ destination: FinderItem) throws -> Void) {
        self.registerFileRepresentation(for: type, openInPlace: true) { loadHandler in
            do {
                let item = try FinderItem.itemReplacementDirectory.appending(path: name)
                
                try handler(item)
                loadHandler(item.url, false, nil)
            } catch {
                loadHandler(nil, false, error)
            }
            
            return nil
        }
    }
    
}
#endif
