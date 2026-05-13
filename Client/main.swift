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


let source = FinderItem(at: "/Users/vaida/DataBase/Swift")
for child in try source.children(range: .enumeration) {
    guard let string = try? child.load(.string) else { continue }
    if string.contains("NSTemporaryDirectory") {
        print(child)
    }
}
#endif
