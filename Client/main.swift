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

let item = FinderItem(at: "/Volumes/Vaida's T7S/Anime/[Nekomoe kissaten&VCB-Studio] Sousou no Frieren [Ma10p_1080p]/[Nekomoe kissaten&VCB-Studio] Sousou no Frieren [01][Ma10p_1080p][x265_flac_aac].mkv")
let source = FinderItem(at: "/Users/vaida/Downloads/Bittorrent Download/[Nekomoe kissaten&VCB-Studio] Sousou no Frieren [Ma10p_1080p]/[Nekomoe kissaten&VCB-Studio] Sousou no Frieren [01][Ma10p_1080p][x265_flac_aac].mkv")

let date = Date()
try print(item.contentsEqual(to: source))
//print(FileManager.default.contentsEqual(atPath: item.path, andPath: source.path))
print(date.distanceToNow())
#endif
