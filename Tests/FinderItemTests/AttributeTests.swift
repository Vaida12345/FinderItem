//
//  AttributeTests.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-25.
//

import FinderItem
import Testing
import Foundation
#if os(macOS)
import AppKit
#endif


@Suite
struct AttributeTests {
    
    private func withTemporaryFile(
        _ body: (FinderItem) throws -> Void
    ) throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        let file = temp/"FILE"
        try Data("contents".utf8).write(to: file)
        try body(file)
    }
    
    @Test func fileManagerAttributes() throws {
        try withTemporaryFile { file in
            let created = Date(timeIntervalSince1970: 1_700_000_000)
            let modified = Date(timeIntervalSince1970: 1_700_000_100)
            try FileManager.default.setAttributes([
                .creationDate: created,
                .modificationDate: modified,
                .posixPermissions: 0o640
            ], ofItemAtPath: file.path)
            
            let attributes = try file.attributes
            #expect(attributes.fileSize == 8)
            #expect(attributes.creationDate == created)
            #expect(attributes.modificationDate == modified)
            #expect(attributes.referenceCount ?? 0 >= 1)
            #expect(attributes.owner != nil)
            #expect(attributes.groupOwner != nil)
            #expect(attributes.readOnly == false)
            #expect(attributes.appendOnly == false)
            #expect(attributes.extensionHidden == false)
            #expect(attributes.permissions?.rawValue == 0o640)
        }
    }
    
    @Test func urlResourceAttributes() throws {
        try withTemporaryFile { file in
            let attributes = try file.attributes
            try #expect(attributes.isApplication == false)
            try #expect(attributes.isAliasFile == false)
            try #expect(attributes.isPackage == false)
            try #expect(attributes.isExecutable == false)
            try #expect(attributes.isHidden == false)
            try #expect(attributes.isSymbolicLink == false)
            try #expect(attributes.writable == true)
            try #expect(attributes.readable == true)
            try #expect(attributes.accessDate != nil)
            try #expect(attributes.displayType != nil)
        }
    }
    
    @Test func xattrAttributes() throws {
        try withTemporaryFile { file in
            let raw = Data("raw value".utf8)
            try file.attributes.update(.xattr("dev.vaida.finderitem.test"), to: raw)
            try file.attributes.update(.downloadDate, to: Date(timeIntervalSince1970: 1_700_001_000))
            try file.attributes.update(.origin, to: "https://example.com/file")
            try file.attributes.update(.comments, to: "comment")
            try file.attributes.update(.keywords, to: ["alpha", "beta"])
            try file.attributes.update(.fileDescription, to: "description")
            try file.attributes.update(.encodingApplications, to: "FinderItemTests")
            try file.attributes.update(.tags, to: ["red", "blue"])
            try file.attributes.update(.xattrIcon, to: .systemImage("doc"))
            
            let attributes = try file.attributes
            try #expect(attributes.xattr.contains("dev.vaida.finderitem.test"))
            try #expect(attributes.xattr("dev.vaida.finderitem.test") == raw)
            try #expect(attributes.xattr("dev.vaida.finderitem.test", as: String.self) == "raw value")
            try #expect(attributes.downloadDate == Date(timeIntervalSince1970: 1_700_001_000))
            try #expect(attributes.origin == "https://example.com/file")
            try #expect(attributes.comments == "comment")
            try #expect(attributes.keywords == ["alpha", "beta"])
            try #expect(attributes.fileDescription == "description")
            try #expect(attributes.encodingApplications == "FinderItemTests")
            try #expect(attributes.tags == ["red", "blue"])
            try #expect(attributes.xattrIcon == .systemImage("doc"))
        }
    }
    
#if os(macOS)
    @Test func quarantineAttribute() throws {
        try withTemporaryFile { file in
            let quarantine = [
                "LSQuarantineAgentName": "FinderItemTests",
                "LSQuarantineType": "LSQuarantineTypeOtherDownload"
            ]
            try file.attributes.update(.quarantine, to: quarantine)
            
            let attributes = try file.attributes.quarantine
            #expect(attributes?["LSQuarantineAgentName"] as? String == "FinderItemTests")
            #expect(attributes?["LSQuarantineType"] as? String == "LSQuarantineTypeOtherDownload")
            
            try file.attributes.update(.quarantine, to: nil)
        }
    }
#endif
    
    @Test func emptyFile() async throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        let empty = temp/"EMPTY"
        try Data().write(to: empty)
        
        try #require(temp.exists)
        let attributes = try empty.attributes
        
        try #expect(!attributes.hasCustomIcon)
        try #expect(attributes.downloadDate == nil)
        try #expect(attributes.origin == nil)
        try #expect(attributes.comments == nil)
        try #expect(attributes.keywords == nil)
        try #expect(attributes.fileDescription == nil)
        try #expect(attributes.encodingApplications == nil)
        try #expect(attributes.tags == nil)
        try #expect(attributes.xattrIcon == nil)
    }
    
    @Test func setEmptyList() async throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        let file = temp/"FILE"
        try Data().write(to: file)
        
        try #require(file.exists)
        try file.attributes.update(.keywords, to: [])
        try file.attributes.update(.tags, to: [])
        
        let attributes = try file.attributes
        try #expect(attributes.keywords == [])
        try #expect(attributes.tags == [])
    }
    
    @Test func setNonEmptyList() async throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        let file = temp/"FILE"
        try Data().write(to: file)
        
        try #require(file.exists)
        try file.attributes.update(.keywords, to: ["a", "b", "b"])
        try file.attributes.update(.tags, to: ["1", "2", "3"])
        
        let attributes = try file.attributes
        try #expect(attributes.keywords == ["a", "b", "b"])
        try #expect(attributes.tags == ["1", "2", "3"])
    }
    
#if os(macOS)
    @Test func setCustomIcon() async throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        let file = temp/"FILE"
        try Data().write(to: file)
        
        try #require(file.exists)
        file.setIcon(image: NSImage(named: NSImage.applicationIconName)!)
        
        let attributes = try file.attributes
        try #expect(attributes.hasCustomIcon)
    }
#endif
    
    @Test func setHidden() async throws {
        let temp = FinderItem.temporaryDirectory.appending(path: UUID().uuidString)
        try temp.makeDirectory()
        defer { try? temp.remove() }
        
        let file = temp/"FILE"
        try Data().write(to: file)
        
        try #require(file.exists)
        try file.attributes.update(.isHidden, to: true)
        
        let attributes = try file.attributes
        try #expect(attributes.isHidden == true)
    }
}
