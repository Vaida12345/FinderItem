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


let item = FinderItem(at: "/Users/vaida/Desktop/text.txt")
try item.insertAttribute(.extensionHidden)
#endif
