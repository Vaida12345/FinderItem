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

let item = FinderItem(at: "/Users/vaida/Desktop/file.mid")
detailedPrint(item, configuration: .showFileSize)
#endif
