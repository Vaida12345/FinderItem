//
//  Playgrounds.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-13.
//

import UniformTypeIdentifiers


extension FinderItem: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        PlaygroundDescription(
            name: self.name,
            path: self.path,
            contentType: try? self.contentType.identifier,
            children: try? self.children(range: .contentsOfDirectory).map(\.self)
        )
    }
    
    public struct PlaygroundDescription {
        
        let name: String
        
        let path: String
        
        let contentType: String?
        
        let children: [FinderItem]?
        
    }
}


#if canImport(Playgrounds) && os(macOS)
import Playgrounds
import SwiftUI

#Playground {
    let item = try FinderItem.temporaryDirectory(intent: .general)
    
}
#endif
