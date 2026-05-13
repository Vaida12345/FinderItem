//
//  FileManager + Attributes.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem {
    
    /// Returns the attributes of the item at a given path, by consulting `FileManager`.
    public var attributes: [FileAttributeKey: Any] {
        get throws(FileError) {
            do {
                return try FileManager.default.attributesOfItem(atPath: path)
            } catch {
                throw FileError.parse(error)
            }
        }
    }
    
    /// Sets the attributes of the specified file or directory.
    public func update(attributes: [FileAttributeKey: Any]) throws {
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: path)
        } catch {
            throw FileError.parse(error)
        }
    }
    
}
