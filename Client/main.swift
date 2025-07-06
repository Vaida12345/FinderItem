//
//  main.swift
//  FinderItem
//
//  Created by Vaida on 12/28/24.
//

#if os(macOS)
import FinderItem
import AppKit
import DetailedDescription


let item = FinderItem(at: "/Users/vaida/Downloads/Safari download/vocab.json")

detailedPrint(item.extendedAttributes!)
try await item.load(.customIcon)?.tiffRepresentation?.write(to: .desktopDirectory/"file.tiff")
#endif
