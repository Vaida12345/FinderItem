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
