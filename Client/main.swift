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


do {
    try print(FileManager.default.url(for: .documentationDirectory, in: .userDomainMask, appropriateFor: .homeDirectory, create: true).standardizedFileURL)
} catch {
    dump(error)
}
#endif
