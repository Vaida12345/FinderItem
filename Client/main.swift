//
//  main.swift
//  FinderItem
//
//  Created by Vaida on 12/28/24.
//

import FinderItem
import AppKit
import DetailedDescription


let item = FinderItem(at: "/Users/vaida/Downloads/Safari download/vocab.json")

detailedPrint(item.extendedAttributes!)
print(item.extendedAttributes?.origin)
