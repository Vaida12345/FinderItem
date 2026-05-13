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
    /// When the dragged item is a file or a directory url, the original item is used. When the item is data, a temporary copy is created, and you should remove the copy once finished.
    public static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.url, importing: { FinderItem(_url: $0) })
        FileRepresentation(importedContentType: .data, shouldAttemptToOpenInPlace: true) { received in // import type cannot be `item`, otherwise it would attempt to copy any file (folder) dragged into `dragDestination`.
            guard !received.isOriginalFile else {
                return FinderItem(_url: received.file)
            }
            let copy = FinderItem.temporaryDirectory.appending(path: received.file.lastPathComponent).generateUniquePath()
            
            // must use file manager, otherwise bad access
            try FileManager.default.copyItem(at: received.file, to: copy.url)
            
            return copy
        }
    }
    
}
