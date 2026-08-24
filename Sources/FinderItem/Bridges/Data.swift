//
//  Data Extensions.swift
//  The FinderItem Module - Extended Functionalities
//
//  Created by Vaida on 2023/12/29.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import CryptoKit
import Compression


public extension Data {
    
    /// Writes the contents of the data buffer to a location.
    ///
    /// If the destination file already exists, the file is replaced atomically.
    ///
    /// - Parameters:
    ///   - destination: The item representing the location to which the data is saved.
    ///   - mode: The mode for writing
    @inlinable
    func write(to destination: FinderItem, mode: Mode = .normal) throws {
        switch mode {
        case .append:
            if let fileHandle = try? FileHandle(forWritingTo: destination.url) {
                try fileHandle.seekToEnd()
                try fileHandle.write(contentsOf: self)
                try fileHandle.close()
            } else {
                fallthrough
            }
        default:
            try self.write(to: destination.url, options: .atomic)
        }
    }
    
    /// The mode for writing
    enum Mode: Sendable {
        
        /// The normal mode, with error thrown if file exists.
        case normal
        
        /// The append mode, append contents without reading or modifying the exiting file.
        case append
    }
    
    /// Initialize with the contents at the specified `FinderItem`.
    ///
    /// - Parameters:
    ///   - source: The `FinderItem` representing the location of the asset.
    ///   - options: Options for loading data.
    @inlinable
    init(at source: FinderItem, options: NSData.ReadingOptions = []) throws {
        try self.init(contentsOf: source.url, options: options)
    }
    
}
