//
//  main.swift
//  FinderItem
//
//  Created by Vaida on 12/28/24.
//

#if os(macOS)
import FinderItem
import Foundation
import DetailedDescription

let root = FinderItem(at: "~")

for child in try root.children(range: .enumeration) {
    guard let tags = try? child.load(.tags) else { continue  }
    if tags.contains(where: { $0.hasPrefix("黄色") }) {
        print(child)
    }
}
#endif
