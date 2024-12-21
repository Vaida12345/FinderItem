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
    ///
    /// To work with finder path copy, the leading and trailing `"` or `'` are trimmed.
    public convenience init(stringLiteral value: String) {
        self.init(at: value.trimmingCharacters(in: ["\"", "\'"]))
    }
    
}
