//
//  Transfer.swift
//  The FinderItem Module
//
//  Created by Vaida on 6/15/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import CoreTransferable


extension FinderItem: Transferable {
    
    /// The transferable representations.
    ///
    /// On dragged, the *original* file is used. Which means that one file can only be dragged once.
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.url, importing: FinderItem.init)
        FileRepresentation(importedContentType: .image) { received in
            guard !received.isOriginalFile else { return FinderItem(at: received.file) }
            let copy = FinderItem.temporaryDirectory.appending(path: received.file.lastPathComponent)
            try copy.removeIfExists()
            
            // must use file manager, otherwise bad access
            try FileManager.default.copyItem(at: received.file, to: copy.url)
            
            return copy
        }
    }
    
}
