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
        ProxyRepresentation(exporting: \.url) { url in
            FinderItem(at: url)
        }
    }
    
}
