//
//  FinderItemTests.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/5/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(Testing)
@testable
import FinderItem
import Testing
import Foundation


extension Tag {
    @Tag static var fileOperations: Tag
}


@Suite("FinderItem Tests")
struct FinderItemTests {
    
    @Test("Test Properties")
    func testProperties() async throws {
        #expect(FinderItem(at: "/Users/vaida/Desktop").description == "/Users/vaida/Desktop/")
        #expect((FinderItem(at: "/Users/vaida/Desktop").path == "/Users/vaida/Desktop/"))
        
        #expect((FinderItem(at: "/Users/vaida/Desktop").userFriendlyDescription == "~/Desktop/"))
        #expect((FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase").userFriendlyDescription == "iCloud Drive/DataBase/"))
        
        #expect((FinderItem(at: "/Users/vaida/Desktop").enclosingFolder.path == FinderItem(at: "/Users/vaida/").path))
        
        #expect((FinderItem(at: "/Users/vaida/Desktop").name == "Desktop"))
        #expect((FinderItem(at: "/Users/vaida/Desktop/file.txt").name == "file.txt"))
        #expect((FinderItem(at: "/Users/vaida/Desktop").extension == ""))
        #expect((FinderItem(at: "/Users/vaida/Desktop/file.txt").extension == "txt"))
        
        #expect((FinderItem(at: "/Users/vaida/Desktop").stem == "Desktop"))
        #expect((FinderItem(at: "/Users/vaida/Desktop/file.txt").stem == "file"))
        #expect((FinderItem(at: "/Users/vaida/Desktop/file.tar.gz").stem == "file.tar"))
        
        try #expect((FinderItem(at: "/Users/vaida/Desktop").fileType == [.directory]))
        
        #expect(throws: FinderItem.FileError.cannotRead(reason: .noSuchFile), performing: {
            try FinderItem(at: "/Users/me/Desktop/file.txt").fileType
        })
    }
    
    @Test("Test File Wrapper")
    func testFileWrapper() async throws {
        let item = FinderItem.desktopDirectory
        let itemProvider = NSItemProvider(at: item)!
        let _dest = try await FinderItem(from: itemProvider).path
        #expect((item.path == _dest))
    }
    
    @Test("Test Methods")
    func testMethods() async throws {
        #expect((FinderItem(at: "/Users/vaida/Desktop").relativePath(to: "/Users/vaida") == "Desktop/"))
        #expect((FinderItem(at: "/Users/vaida/Desktop").relativePath(to: "/Users/vaida/") == "Desktop/"))
        
        #expect((FinderItem(at: "/Users/vaida/Desktop/file.txt").replacingExtension(with: "png").path == "/Users/vaida/Desktop/file.png"))
        #expect((FinderItem(at: "/Users/vaida/Desktop/file").replacingExtension(with: "png").path == "/Users/vaida/Desktop/file.png"))
        
        #expect(FinderItem.normalize(shellPath: #"/Users/vaida/Downloads/Bittorrent\ Download/\[VCB-Studio\]\ Mahouka\ Koukou\ no\ Rettousei/\[VCB-Studio\]\ Mahouka\ Koukou\ no\ Rettousei\ Hoshi\ o\ Yobu\ Shoujo\ \[Ma10p_1080p\]/CDs/\[180124\]\ ORIGINAL\ SOUNDTRACK／岩崎琢\ \[24bit_48KHz\]\ \(flac\)/05.\ release.flac.\!qB "#, shouldRemoveTrailingSpace: true) == #"/Users/vaida/Downloads/Bittorrent Download/[VCB-Studio] Mahouka Koukou no Rettousei/[VCB-Studio] Mahouka Koukou no Rettousei Hoshi o Yobu Shoujo [Ma10p_1080p]/CDs/[180124] ORIGINAL SOUNDTRACK／岩崎琢 [24bit_48KHz] (flac)/05. release.flac.!qB"#)
    }
    
    
    @Test("Test Folders")
    func folders() async throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        // add files
        let string = "12345"
        try string.write(to: folder.appending(path: "file.txt"))
        #expect(try folder.appending(path: "file.txt").load(.string()) == string)
        #expect(folder.appending(path: "file.txt").isFile)
        #expect(!folder.appending(path: "file.txt").isDirectory)
        #expect(folder.appending(path: "file.txt").exists)
        #expect(folder.appending(path: "file.txt").isReadable)
        #expect(folder.appending(path: "file.txt").isWritable)
        
        // add folder
        let subdir = folder.appending(path: "Folder", directoryHint: .isDirectory)
        try subdir.makeDirectory()
        #expect(!subdir.isFile)
        #expect(subdir.isDirectory)
        #expect(subdir.exists)
        #expect(subdir.isReadable)
        #expect(subdir.isWritable)
        
        // add files to subdir
        let value = 123
        try value.data.write(to: subdir.appending(path: "data"))
        #expect(try subdir.appending(path: "data").load(.data) == value.data)
        
        // add hidden file
        let text = "123"
        try text.write(to: folder.appending(path: ".image.txt"))
        #expect(try folder.appending(path: ".image.txt").load(.string()).data() == text.data())
        #expect(try folder.appending(path: ".image.txt").contentType.conforms(to: .text))
        
        // add hidden dir
        let hiddendir = folder.appending(path: ".hidden")
        try hiddendir.makeDirectory()
        
        // add file to hidden dir
        try string.write(to: hiddendir.appending(path: ".file.txt"))
        
        // check children
        try #expect(Array(folder.children(range: .contentsOfDirectory)).count == 2)
        try #expect(Array(folder.children(range: .contentsOfDirectory.withHidden)).count == 4)
        try #expect(Array(folder.children(range: .contentsOfDirectory.withSystemHidden)).count == 4) // without DS_Store
        try #expect(Array(folder.children(range: .enumeration)).count == 3)
        try #expect(Array(folder.children(range: .enumeration.withHidden)).count == 6)
        try #expect(Array(folder.children(range: .exploreDescendants(on: { _ in true }))).count == 3)
        try #expect(Array(folder.children(range: .exploreDescendants(on: { $0.name == "Folder" }))).count == 3)
        try #expect(Array(folder.children(range: .exploreDescendants(on: { _ in false }))).count == 2)
        try #expect(Array(folder.children(range: .exploreDescendants(on: { _ in true }).withHidden)).count == 6)
        try #expect(Array(folder.children(range: .exploreDescendants(on: { $0.name == "Folder" }).withHidden)).count == 5)
        try #expect(Array(folder.children(range: .exploreDescendants(on: { _ in false }).withHidden)).count == 4)
    }
    
    @Test("Test File Operations", .tags(.fileOperations))
    func fileOperations() async throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "file.txt")
        #expect(file.isFile)
        try "12345".write(to: file)
        #expect(file.isFile)
        #expect(file.exists)
        
        #expect(throws: FinderItem.FileError.cannotWrite(reason: .fileExists)) {
            try file.makeDirectory()
        }
        
        let anotherFile = folder.appending(path: "file Copy.txt")
        
        try file.copy(to: anotherFile)
        #expect(anotherFile.exists)
        
        let subdir = folder.appending(path: "folder")
        try file.copy(to: subdir.appending(path: "file.txt"))
        #expect(subdir.appending(path: "file.txt").exists)
        
        try folder.clear()
        #expect(folder.exists)
        #expect(try Array(folder.children(range: .enumeration.withSystemHidden)).isEmpty)
    }
    
    @Test("Test More File Operations", .tags(.fileOperations))
    func moreFileOperations() async throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "A/B/C/D/.E/.file.txt")
        try file.generateDirectory()
        #expect(file.enclosingFolder.exists)
        
        try "1".write(to: file)
        
        let file2 = file.generateUniquePath()
        try "2".write(to: file2)
        
        #expect(file2.name == ".file 2.txt")
        
        let file3 = file2.generateUniquePath()
        try "3".write(to: file3)
        
        #expect(file3.name == ".file 3.txt")
        
        let file4 = file.generateUniquePath()
        try "4".write(to: file4)
        
        #expect(file4.name == ".file 4.txt")
    }
    
    //FIXME: implement moving, rename, edit stem.
    @Test("Test File Moving Operations", .tags(.fileOperations))
    func fileMovingOperations() async throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let target = folder.appending(path: "file.txt")
        let destination = folder.appending(path: "destination.txt")
        try target.write(to: target, format: .json)
        #expect(target.exists)
        #expect(target.isFile)
        
        try target.move(to: destination.url)
        #expect(!folder.appending(path: "file.txt").exists)
        #expect(destination.exists)
        #expect(destination.url == target.url)
        
        try target.rename(with: "file.txt")
        #expect(!destination.exists)
        #expect(target.exists)
        #expect(target.url == folder.appending(path: "file.txt").url)
    }
    
    @Test("Test File Relative Paths")
    func fileRelativePath() throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "/file.txt")
        #expect(file == folder.appending(path: "file.txt"))
        
        #expect(file.relativePath(to: folder) == "file.txt")
    }
    
    @Test
    func immediateRemoval() throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "/file.txt")
        try "123".write(to: file)
        #expect(file.exists)
        
        try file.remove()
        #expect(!file.exists)
    }
    
    @Test
    func immediateMove() throws {
        let folder = try FinderItem.temporaryDirectory(intent: .general).appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "/file.txt")
        try "123".write(to: file)
        #expect(file.exists)
        
        try file.move(to: folder.appending(path: "/file 2.txt").url)
        #expect(!folder.appending(path: "/file.txt").exists)
        #expect(folder.appending(path: "/file 2.txt").exists)
    }
    
}


private extension BinaryInteger {
    
    /// The raw data that made up the binary integer.
    var data: Data {
        withUnsafePointer(to: self) { pointer in
            pointer.withMemoryRebound(to: UInt8.self, capacity: bitWidth / 8) { pointer in
                Data(bytes: pointer, count: bitWidth / 8)
            }
        }
    }
    
    /// Creates a integer using the given data.
    ///
    /// - Note: If the width of `data` is greater than `Self.max`, if `self` is fixed width, the result is truncated.
    init(data: Data) {
        let tuple = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
        defer { tuple.deallocate() }
        
        data.copyBytes(to: tuple, count: data.count)
        
        self = tuple.withMemoryRebound(to: Self.self, capacity: 1) { $0.pointee }
    }
    
}
#endif
