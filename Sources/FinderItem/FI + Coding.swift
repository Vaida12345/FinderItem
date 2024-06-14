//
//  FinderItem + Coding.swift
//  The Stratum Module
//
//  Created by Vaida on 5/1/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


// MARK: - Codable

extension FinderItem: Codable {
    
    /// Encode the finderItem using the `encoder`.
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.url)
    }
    
    /// Decode the finderItem from the `decoder`.
    @inlinable
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let url = try container.decode(URL.self)
        self.init(at: url)
    }
}
