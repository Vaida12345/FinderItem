//
//  FinderItem + String.swift
//  The FinderItem Module
//
//  Created by Vaida on 2024/3/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


extension FinderItem: ExpressibleByStringInterpolation {
    
    /// This is an convenience initializer for ``FinderItem/init(at:directoryHint:)``.
    public init(stringLiteral value: String) {
        self.init(at: value)
    }
    
}
