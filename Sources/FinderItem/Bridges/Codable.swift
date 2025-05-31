//
//  Codable Extensions.swift
//  The FinderItem Module - Extended Functionalities
//
//  Created by Vaida on 8/18/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation
import Essentials

public extension Decodable {
    
    /// Initialize from `source` which is of `format`.
    ///
    /// - Parameters:
    ///   - source: The location of source data.
    ///   - format: The format in which the data is.
    @inlinable
    init(at source: FinderItem, format: Data.CodingFormat) throws {
        self = try Data(at: source).decoded(type: Self.self, format: format)
    }
    
}


public extension Encodable {
    
    /// Write the structure to disk using the given `format`.
    ///
    /// - Parameters:
    ///   - destination: The destination file location.
    ///   - format: The format used.
    @inlinable
    func write(to destination: FinderItem, format: Data.CodingFormat) throws {
        try self.data(using: format).write(to: destination)
    }
    
}
