//
//  FileAttribute.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-07.
//

import Foundation


extension FinderItem {
    
    /// Loads a file attribute.
    public func load<T>(_ attributeKey: FileAttributeKey<T>) throws -> T? {
        try attributeKey.load(self)
    }
    
    public struct FileAttributeKey<Value> {
        
        let load: (_ source: FinderItem) throws -> Value?
        
    }
}


extension FinderItem.FileAttributeKey {
    
    /// Indicates whether the file’s extension is hidden.
    public static var extensionHidden: FinderItem.FileAttributeKey<Bool> {
        .init { source in
            (try FileManager.default.attributesOfItem(atPath: source.path)[.extensionHidden] as? NSNumber)?.boolValue
        }
    }
    
}
