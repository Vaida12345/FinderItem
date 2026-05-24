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
import CoreTransferable


extension Tag {
    @Tag static var fileOperations: Tag
}


@Suite("FinderItem Tests")
struct FinderItemTests {
    
    private func withTemporaryDirectory(
        _ body: (FinderItem) throws -> Void
    ) throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try folder.makeDirectory()
        defer { try? folder.remove() }
        try body(folder)
    }
    
    @Test("Test Properties")
    func testProperties() async throws {
        try withTemporaryDirectory { folder in
            let file = folder.appending(path: "file.txt")
            let archive = folder.appending(path: "file.tar.gz")
            let extensionlessFile = folder.appending(path: "file")
            
            #expect(file.enclosingFolder.path == folder.path)
            #expect(folder.path.hasSuffix("/"))
            #expect(folder.enclosingFolder.appending(path: folder.name).path == folder.path.dropLast())
            
            #expect(folder.name == folder.url.lastPathComponent)
            #expect(file.name == "file.txt")
            #expect(folder.extension == "")
            #expect(file.extension == "txt")
            #expect(extensionlessFile.extension == "")
            
            #expect(folder.stem == folder.name)
            #expect(file.stem == "file")
            #expect(archive.stem == "file.tar")
            #expect(extensionlessFile.stem == "file")
        }
    }
    
    @Test("Test Hidden File Names")
    func hiddenFileNames() {
        let file = FinderItem.temporaryDirectory/".hidden"
        #expect(file.stem == ".hidden")
        #expect(file.extension.isEmpty)
        
        let file2 = FinderItem.temporaryDirectory/".hidden.tar.gz"
        #expect(file2.stem == ".hidden.tar")
        #expect(file2.extension == "gz")
    }
    
    #if os(macOS)
    @Test("Test File Wrapper")
    func testFileWrapper() async throws {
        let item = try FinderItem.documentsDirectory
        let itemProvider = NSItemProvider(at: item)!
        let _dest = try await FinderItem(from: itemProvider).path
        #expect((item.path == _dest))
    }
    #endif
    
    @Test("Test Methods")
    func testMethods() async throws {
        try withTemporaryDirectory { folder in
            let child = folder.appending(path: "child", directoryHint: .isDirectory)
            let nestedFile = child.appending(path: "file.txt")
            let fileWithoutExtension = child.appending(path: "file")
            
            #expect(child.relativePath(to: folder) == "child")
            #expect(nestedFile.relativePath(to: folder) == "child/file.txt")
            #expect(child.relativePath(to: child) == "")
            #expect(FinderItem(at: child.path + "/").relativePath(to: child) == "")
            #expect(child.relativePath(to: FinderItem.temporaryDirectory.appending(path: UUID().uuidString)) == nil)
            
            #expect(nestedFile.replacingExtension(with: "png").path == child.appending(path: "file.png").path)
            #expect(fileWithoutExtension.replacingExtension(with: "png").path == child.appending(path: "file.png").path)
            #expect(nestedFile.replacingExtension(with: "").path == fileWithoutExtension.path)
            #expect(nestedFile.replacingStem(with: "image").path == child.appending(path: "image.txt").path)
        }
    }
    
    
    @Test("Test Folders")
    func folders() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        // add files
        let string = "12345"
        try string.write(to: folder.appending(path: "file.txt"))
        #expect(try folder.appending(path: "file.txt").load(.string()) == string)
        #expect(folder.appending(path: "file.txt").isFile)
        #expect(!folder.appending(path: "file.txt").isDirectory)
        #expect(folder.appending(path: "file.txt").exists)
        try #expect(folder.appending(path: "file.txt").attributes.readable ?? false)
        try #expect(folder.appending(path: "file.txt").attributes.writable ?? false)
        
        // add folder
        let subdir = folder.appending(path: "Folder", directoryHint: .isDirectory)
        try subdir.makeDirectory()
        #expect(!subdir.isFile)
        #expect(subdir.isDirectory)
        #expect(subdir.exists)
        try #expect(subdir.attributes.readable ?? false)
        try #expect(subdir.attributes.writable ?? false)
        
        // add files to subdir
        let value = 123
        try value.data.write(to: subdir.appending(path: "data"))
        #expect(try subdir.appending(path: "data").load(.data) == value.data)
        
        // add hidden file
        let text = "123"
        try text.write(to: folder.appending(path: ".image.txt"))
        #expect(try folder.appending(path: ".image.txt").load(.string()).data(using: .utf8) == text.data(using: .utf8))
        #expect(try folder.appending(path: ".image.txt").contentType?.conforms(to: .text) ?? false)
        
        // add hidden dir
        let hiddendir = folder.appending(path: ".hidden")
        try hiddendir.makeDirectory()
        
        // add file to hidden dir
        try string.write(to: hiddendir.appending(path: ".file.txt"))
        
        // check children
        func paths(_ range: FinderItem.ChildrenRange) throws -> [String] {
            try folder.children(range: range).map { try #require($0.relativePath(to: folder)) }
        }
        
        try #expect(paths(.contentsOfDirectory) == ["file.txt", "Folder"])
        try #expect(paths(.contentsOfDirectory.withHidden) == [".hidden", ".image.txt", "file.txt", "Folder"])
        try #expect(paths(.contentsOfDirectory.withSystemHidden) == [".hidden", ".image.txt", "file.txt", "Folder"]) // without DS_Store
        try #expect(paths(.enumeration) == ["file.txt", "Folder", "Folder/data"])
        try #expect(paths(.enumeration.withHidden) == [".hidden", ".hidden/.file.txt", ".image.txt", "file.txt", "Folder", "Folder/data"])
        try #expect(paths(.exploreDescendants(on: { _ in true })) == ["file.txt", "Folder", "Folder/data"])
        try #expect(paths(.exploreDescendants(on: { $0.name == "Folder" })) == ["file.txt", "Folder", "Folder/data"])
        try #expect(paths(.exploreDescendants(on: { _ in false })) == ["file.txt", "Folder"])
        try #expect(paths(.exploreDescendants(on: { _ in true }).withHidden) == [".hidden", ".hidden/.file.txt", ".image.txt", "file.txt", "Folder", "Folder/data"])
        try #expect(paths(.exploreDescendants(on: { $0.name == "Folder" }).withHidden) == [".hidden", ".image.txt", "file.txt", "Folder", "Folder/data"])
        try #expect(paths(.exploreDescendants(on: { _ in false }).withHidden) == [".hidden", ".image.txt", "file.txt", "Folder"])
    }
    
    @Test("Test File Operations", .tags(.fileOperations))
    func fileOperations() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "file.txt")
        #expect(file.isFile)
        try "12345".write(to: file)
        #expect(file.isFile)
        #expect(file.exists)
        
        let error = try #require(throws: FinderItem.FileError.self) {
            try file.makeDirectory()
        }
        #expect(error.code == .cannotWrite(reason: .fileExists))
        
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
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
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
    
    @Test("Test File Moving Operations", .tags(.fileOperations))
    func fileMovingOperations() async throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
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
        #expect(target.name == "destination.txt")
        
        try target.rename(with: "renamed")
        #expect(!destination.exists)
        #expect(folder.appending(path: "renamed").exists)
        #expect(target.url == folder.appending(path: "renamed").url)
        #expect(target.name == "renamed")
        
        try target.rename(with: "file", keepExtension: true)
        #expect(folder.appending(path: "file").exists)
        #expect(target.url == folder.appending(path: "file").url)
        
        let typedFile = folder.appending(path: "typed.data")
        try Data("typed".utf8).write(to: typedFile)
        try typedFile.rename(with: "typed-renamed", keepExtension: true)
        #expect(typedFile.url == folder.appending(path: "typed-renamed.data").url)
        #expect(typedFile.exists)
    }
    
    @Test("Test File Relative Paths")
    func fileRelativePath() throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "/file.txt")
        #expect(file == folder.appending(path: "file.txt"))
        
        #expect(file.relativePath(to: folder) == "file.txt")
    }
    
    @Test
    func immediateRemoval() throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
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
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let file = folder.appending(path: "/file.txt")
        try "123".write(to: file)
        #expect(file.exists)
        
        try file.move(to: folder.appending(path: "/file 2.txt").url)
        #expect(!folder.appending(path: "/file.txt").exists)
        #expect(folder.appending(path: "/file 2.txt").exists)
    }
    
    @Test
    func contentsEqual() throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().description)
        try folder.makeDirectory()
        defer { try! folder.remove() }
        
        let source = folder.appending(path: "/source.txt")
        let buffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 1024)
        defer { buffer.deallocate() }
        var data = Data(bytesNoCopy: buffer.baseAddress!, count: buffer.count, deallocator: .none)
        try data.write(to: source)
        
        let destination1 = folder.appending(path: "/destination1.txt")
        try source.copy(to: destination1)
        
        #expect(try source.contentsEqual(to: destination1))
        
        let destination2 = folder.appending(path: "/destination2.txt")
        data[data.count - 1] &+= 1
        try data.write(to: destination2)
        
        #expect(try !source.contentsEqual(to: destination2))
    }
    
    @Test
    @available(macOS 15.2, iOS 18.2, *)
    func transferableTest() async throws {
        #expect(FinderItem.exportedContentTypes() == [.url, .fileURL])
        #expect(FinderItem.importedContentTypes() == [.url, .fileURL, .data])
    }
    
    @Test("POSIX Permissions Decode")
    func posixPermissionsDecode() {
        let permissions = FinderItem.Attributes.Permissions(rawValue: 0o6754)
        
        #expect(permissions.owner == .init(read: true, write: true, execute: true))
        #expect(permissions.group == .init(read: true, write: false, execute: true))
        #expect(permissions.others == .init(read: true, write: false, execute: false))
        #expect(permissions.setUserID)
        #expect(permissions.setGroupID)
        #expect(!permissions.sticky)
    }
    
    @Test("POSIX Permissions Encode")
    func posixPermissionsEncode() {
        let permissions = FinderItem.Attributes.Permissions(
            owner: .init(read: true, write: true, execute: true),
            group: .init(read: true, write: false, execute: true),
            others: .init(read: false, write: false, execute: true),
            setUserID: false,
            setGroupID: false,
            sticky: true
        )
        
        #expect(permissions.rawValue == 0o1751)
    }
    
    @Test
    func assumeURLAndFileManagerReturnsSameEnvironmentDirectories() throws {
        try #require(FinderItem.url(for: .documentDirectory).url == .documentsDirectory)
        try #require(FinderItem.url(for: .applicationSupportDirectory).url == .applicationSupportDirectory)
        try #require(FinderItem.url(for: .cachesDirectory).url == .cachesDirectory)
        try #require(FinderItem.url(for: .libraryDirectory).url == .libraryDirectory)
        try #require(FinderItem.url(for: .downloadsDirectory).url == .downloadsDirectory)
        try #require(FinderItem.url(for: .musicDirectory).url == .musicDirectory)
        try #require(FinderItem.url(for: .picturesDirectory).url == .picturesDirectory)
        try #require(FileManager.default.temporaryDirectory == .temporaryDirectory)
        #if os(macOS)
        try #require(FinderItem.url(for: .trashDirectory).url == .trashDirectory)
        #endif
    }
    
    @Test
    func testFileOrder() throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        try Data().write(to: temp/"1")
        try Data().write(to: temp/"2")
        try Data().write(to: temp/"10")
        try Data().write(to: temp/"100")
        try Data().write(to: temp/"00101")
        try Data().write(to: temp/"00000")
        
        #expect(try temp.children(range: .contentsOfDirectory).map(\.stem) == ["00000", "1", "2", "10", "100", "00101"])
        #expect(try temp.children(range: .enumeration).map(\.stem) == ["00000", "1", "2", "10", "100", "00101"])
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
