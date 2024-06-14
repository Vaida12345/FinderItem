//
//  FinderItem + Configurable Coding.swift
//  The Stratum Module
//
//  Created by Vaida on 6/25/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


extension FinderItem {
    
    fileprivate enum ConfigurableCodingKey: String, CodingKey {
        
        /// The key indicating the path of the FinderItem.
        case bookmarkDataKey = "data"
        
        /// The key indicating the parent path of the FinderItem.
        case parentKey = "parent"
        
    }
    
}


extension FinderItem: EncodableWithConfiguration {
    
    public func encode(to encoder: Encoder, configuration: NSURL.BookmarkCreationOptions) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(self.url.bookmarkData(options: configuration,
                                                   includingResourceValuesForKeys: nil,
                                                   relativeTo: nil))
    }
    
    
    public typealias EncodingConfiguration = URL.BookmarkCreationOptions
    
}


extension FinderItem: DecodableWithConfiguration {
    
    public convenience init(from decoder: Decoder, configuration: URL.BookmarkResolutionOptions) throws {
        let data: Data
        
        if let container = try? decoder.container(keyedBy: ConfigurableCodingKey.self) {
            data = try container.decode(Data.self, forKey: .bookmarkDataKey)
        } else {
            let container = try decoder.singleValueContainer()
            data = try container.decode(Data.self)
        }
        
        var bookmarkDataIsStale = false
        let url = try URL(resolvingBookmarkData: data,
                          options: configuration,
                          relativeTo: nil,
                          bookmarkDataIsStale: &bookmarkDataIsStale)
        
        if let originalPath = try? FileManager.default.destinationOfSymbolicLink(atPath: url.path) {
            self.init(at: originalPath)
        } else {
            self.init(at: url)
        }
    }
    
    public typealias DecodingConfiguration = URL.BookmarkResolutionOptions
    
}
