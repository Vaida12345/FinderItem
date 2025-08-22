//
//  Playgrounds.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-13.
//

import UniformTypeIdentifiers


extension FinderItem: CustomPlaygroundDisplayConvertible {
    
    public var playgroundDescription: Any {
        self.url
    }
}


#if canImport(Playgrounds) && os(macOS)
import Playgrounds
import SwiftUI

#Playground {
    let item = try FinderItem.temporaryDirectory(intent: .general)
    print(item)
}
#endif
