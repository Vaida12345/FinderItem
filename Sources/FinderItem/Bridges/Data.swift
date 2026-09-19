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
    ///   - options: Options for writing the data. Default value is `[.atomic]`.
    @inlinable
    func write(to destination: FinderItem, options: NSData.WritingOptions = [.atomic]) throws {
        try self.write(to: destination.url, options: options)
    }
    
    /// Initialize with the contents at the specified `FinderItem`.
    ///
    /// - Parameters:
    ///   - source: The `FinderItem` representing the location of the asset.
    ///   - options: Options for loading data. Default value is `[.mappedIfSafe]`.
    @inlinable
    init(at source: FinderItem, options: NSData.ReadingOptions = [.mappedIfSafe]) throws {
        try self.init(contentsOf: source.url, options: options)
    }
    
}
