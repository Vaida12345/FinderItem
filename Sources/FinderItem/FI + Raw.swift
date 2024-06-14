//
//  FinderItem + RawRepresentable.swift
//  The Stratum Module
//
//  Created by Vaida on 6/22/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


extension FinderItem: RawRepresentable {
    
    /// The raw value for the ``FinderItem``, which is its ``url``.
    @inlinable
    public var rawValue: URL {
        self.url
    }
    
    /// Initialize a ``FinderItem`` with its ``rawValue``.
    ///
    /// - Parameters:
    ///   - rawValue: The absolute ``url``.
    @inlinable
    public convenience init(rawValue: URL) {
        self.init(at: rawValue)
    }
    
}
