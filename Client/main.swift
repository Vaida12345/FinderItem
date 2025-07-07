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


let item = FinderItem(at: "/Users/vaida/Downloads/Safari download/generation_config.json")

detailedPrint(item, configuration: .showExtendedAttributes)
try print(item.load(.xattr))
#endif
