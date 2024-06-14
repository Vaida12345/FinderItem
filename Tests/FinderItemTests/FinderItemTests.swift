//
//  FinderItemTests.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/5/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(Testing)
@testable
import Stratum
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
        #expect((FinderItem(at: "/Users/vaida/Library/Mobile Documents/com~apple~CloudDocs/DataBase/Animation").userFriendlyDescription == "iCloud Drive/DataBase/Animation/"))
        
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
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        
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
        let image = NativeImage(systemSymbolName: "cat", accessibilityDescription: nil)!
        try image.write(to: folder.appending(path: ".image.png"))
        #expect(try folder.appending(path: ".image.png").load(.image).data() == image.data())
        #expect(try folder.appending(path: ".image.png").contentType!.conforms(to: .png))
        
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
        
        // set icon
        folder.setIcon(image: image)
        try #expect(Array(folder.children(range: .contentsOfDirectory.withSystemHidden)).count == 5)
        
        try folder.remove()
    }
    
    @Test("Test Load")
    func load() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        
        #expect(throws: FinderItem.LoadError.encounteredNil) {
            try folder.appending(path: "image.png").load(.image)
        }
        #expect(try folder.icon()?.data() == FinderItem.temporaryDirectory.load(.icon()).data())
        #expect(try folder.load(.icon(size: .square(256))) != nil)
        #expect(try await folder.load(.preview(size: .square(256))) != nil)
        
        try folder.remove()
    }
    
    @Test("Test File Operations", .tags(.fileOperations))
    func fileOperations() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        
        let file = folder.appending(path: "file.txt")
        #expect(try file.isFile)
        try "12345".write(to: file)
        #expect(try file.isFile)
        #expect(try file.exists)
        
        #expect(throws: FinderItem.FileError.cannotWrite(reason: .fileExists)) {
            try file.makeDirectory()
        }
        
        let anotherFile = folder.appending(path: "file Copy.txt")
        
        try file.copy(to: anotherFile)
        #expect(try anotherFile.exists)
        
        try "1".write(to: anotherFile)
        try file.copy(to: anotherFile)
        #expect(try file.contentsEqual(to: anotherFile))
        
        let subdir = folder.appending(path: "folder")
        try file.copy(to: subdir.appending(path: "file.txt"))
        #expect(try subdir.appending(path: "file.txt").exists)
        
        try folder.clear()
        #expect(try folder.exists)
        #expect(try Array(folder.children(range: .enumeration.withSystemHidden)).isEmpty)
        
        try folder.remove()
    }
    
    @Test("Test More File Operations", .tags(.fileOperations))
    func moreFileOperations() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        
        let file = folder.appending(path: "A/B/C/D/.E/.file.txt")
        try file.generateDirectory()
        #expect(try file.enclosingFolder.exists)
        
        try "1".write(to: file)
        
        let file2 = file
        try file2.generateOutputPath()
        try "2".write(to: file2)
        
        #expect(file2.name == ".file 2.txt")
        
        let file3 = file
        try file2.generateOutputPath()
        try "3".write(to: file3)
        
        #expect(file3.name == ".file 3.txt")
        
        
        try folder.remove()
    }
    
    //FIXME: implement moving, rename, edit stem.
    @Test("Test File Moving Operations", .tags(.fileOperations))
    func fileMovingOperations() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        
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
        
        try folder.remove()
    }
    
    @Test("Test File Relative Paths")
    func fileRelativePath() throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        
        let file = folder.appending(path: "/file.txt")
        #expect(file == folder.appending(path: "file.txt"))
        
        #expect(file.relativePath(to: folder) == "file.txt")
        
        try folder.remove()
    }
    
}
#endif
