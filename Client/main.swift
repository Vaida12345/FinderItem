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


let item = FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Projects/Projects/Annotation/Annotation.xcodeproj/")
try await print(item.open())

#endif
