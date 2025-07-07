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
import CoreServices

let item = FinderItem(at: "/Users/vaida/Desktop/file.mid")
detailedPrint(item, configuration: .showExtendedAttributes)
try item.insertAttribute(.encodingApplications, ["FinderItem"])

let mdItem = MDItemCreate(nil, item.path as CFString)
print(MDItemCopyAttribute(mdItem, kMDItemEncodingApplications) as Any)
#endif
