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


let item = FinderItem(at: "/System/Applications/TV.app")

await print(item.open())
try await Task.sleep(for: .seconds(100))

#endif
