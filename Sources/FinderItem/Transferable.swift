//
//  FinderItem + Transferable.swift
//  The FinderItem Module
//
//  Created by Vaida on 7/25/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(CoreTransferable)
import CoreTransferable
import UniformTypeIdentifiers


extension FinderItem: Transferable {
    
    /// The file representation to the `FinderItem`.
    ///
    /// - Note: The original file is accessed.
    @inlinable
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .folder) { item in
            SentTransferredFile(item.url, allowAccessingOriginalFile: true)
        } importing: { receivedFile in
            FinderItem(at: receivedFile.file)
        }
    }
    
}
#endif
