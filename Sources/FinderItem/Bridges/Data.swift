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
        case .normal:
            try self.write(to: destination.url)
        }
    }
    
    /// The mode for writing
    enum Mode {
        
        /// The normal mode, with error thrown if file exists.
        case normal
        
        /// The append mode, append contents without reading or modifying the exiting file.
        case append
    }
    
    /// Initialize with the contents at the specified `FinderItem`.
    ///
    /// - Parameters:
    ///   - source: The `FinderItem` representing the location of the asset.
    @inlinable
    init(at source: FinderItem) throws {
        try self.init(contentsOf: source.url)
    }
    
    /// Compress the data using the given algorithm lossless-ly.
    @inlinable
    func compressed(using algorithm: Compression.Algorithm = .lzfse, pageSize: Int = 128) throws -> Data {
        var compressedData = Data()
        let outputFilter = try OutputFilter(.compress, using: algorithm) { data in
            if let data { compressedData.append(data) }
        }
        
        var index = 0
        let bufferSize = self.count
        
        while true {
            let rangeLength = Swift.min(pageSize, bufferSize - index)
            
            let subdata = self.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            try outputFilter.write(subdata)
            
            if (rangeLength == 0) { break }
        }
        
        return compressedData
    }
    
    /// Decompress the data using the given algorithm lossless-ly.
    @inlinable
    func decompressed(using algorithm: Compression.Algorithm = .lzfse, pageSize: Int = 128) throws -> Data {
        var decompressedData = Data()
        
        var index = 0
        let bufferSize = self.count
        
        let inputFilter = try InputFilter(.decompress, using: algorithm) { (length: Int) -> Data? in
            let rangeLength = Swift.min(length, bufferSize - index)
            let subdata = self.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            return subdata
        }
        
        while let page = try inputFilter.readData(ofLength: pageSize) {
            decompressedData.append(page)
        }
        
        return decompressedData
    }
    
}
