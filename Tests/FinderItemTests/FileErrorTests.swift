//
//  FileErrorTests.swift
//  FinderItem
//
//  Created by Vaida on 2026-10-30.
//

@testable
import FinderItem
import Testing
import Foundation
import System


/// Most tests assert what an error says about itself (the reason, the items, the intent), and that its message is non-empty, names the file, and is never a placeholder. Those hold on every OS and in every language.
///
/// The tests of real errors (`messageOfRealErrors` and `detailsOfRealErrors`) also assert the exact text, which is what Foundation says on macOS 27, in English. When Foundation rewords an error, such a test fails and shows the new text.
@Suite("FileError Tests")
struct FileErrorTests {

    typealias FileError = FinderItem.FileError

    /// Whether Foundation words its errors in English in this process. The expectations of the tests of real errors are in English.
    static let foundationSpeaksEnglish = Bundle.main.preferredLocalizations.first == "en"

    private func withTemporaryDirectory(
        _ body: (FinderItem) throws -> Void
    ) throws {
        let folder = FinderItem.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try folder.makeDirectory()
        defer { try? folder.remove() }
        try body(folder)
    }

    /// Runs `body`, which must throw a `FileError`.
    private func thrownError(_ body: () throws -> Void) throws -> FileError {
        try #require(throws: FileError.self) { try body() }
    }

    /// Expects `body` to throw a `FileError` whose message is exactly `message`.
    private func expectMessage(
        _ message: String,
        from body: () throws -> Void,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let error = try thrownError(body)
        #expect(error.message == message, sourceLocation: sourceLocation)
    }


    // MARK: - Classification

    @Test("A missing file is `noSuchFile`, whichever operation notices")
    func missingFile() throws {
        try withTemporaryDirectory { folder in
            let existing = folder/"existing.txt"
            try "hello".write(to: existing)
            let missing = folder/"missing.txt"
            let target = folder/"target.txt"

            let operations: [(name: String, body: () throws -> Void)] = [
                ("remove", { try missing.remove() }),
                ("move", { try missing.move(to: target.url) }),
                ("move into a missing folder", { try existing.move(to: (folder/"nope/inside/file.txt").url) }),
                ("copy", { try missing.copy(to: target) }),
                ("replace", { try missing.replace(existing) }),
                ("moveToTrash", { try missing.moveToTrash() }),
                ("contentType", { _ = try missing.contentType }),
                ("children", { _ = try missing.children(range: .contentsOfDirectory) }),
                ("Data(at:)", { _ = try Data(at: missing) }),
                ("String(at:)", { _ = try String(at: missing) }),
                ("load", { _ = try missing.load(.data) }),
                ("xattr", { _ = try missing.attributes.xattr("com.example.test") }),
                ("contentsEqual", { _ = try missing.contentsEqual(to: existing) }),
                ("updateCurrentDirectory", { try FinderItem.updateCurrentDirectory(to: missing) }),
                ("bundleItem", { _ = try FinderItem.bundleItem(forResource: "definitely-missing", withExtension: "none") }),
            ]

            for (name, body) in operations {
                let error = try thrownError(body)
                #expect(error.reason == .noSuchFile, "\(name)")
                #expect(!error.message.isEmpty, "\(name)")
                #expect(error.message != "(unknown)", "\(name)")
                let namesAnItem = error.message.contains(error.source.stem) || (error.destination.map { error.message.contains($0.stem) } ?? false)
                #expect(namesAnItem, "\(name): \(error.message)")
            }
        }
    }

    @Test("An existing item is `fileExists`")
    func fileExists() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"file.txt"
            let other = folder/"other.txt"
            try "1".write(to: file)
            try "2".write(to: other)

            #expect(try thrownError { try file.makeDirectory() }.reason == .fileExists)
            #expect(try thrownError { try file.copy(to: other) }.reason == .fileExists)
        }
    }

    @Test("A directory where a file is expected is `isDirectory`")
    func isDirectory() throws {
        try withTemporaryDirectory { folder in
            let directoryA = folder/"directoryA"
            let directoryB = folder/"directoryB"
            try directoryA.makeDirectory()
            try directoryB.makeDirectory()

            let read = try thrownError { _ = try Data(at: directoryA) }
            #expect(read.reason == .isDirectory)
            #expect(read.errno == .isDirectory)
            #expect(read.message.contains(directoryA.stem))

            let compare = try thrownError { _ = try directoryA.contentsEqual(to: directoryB) }
            #expect(compare.reason == .isDirectory)
            #expect(compare.source == directoryA)
            #expect(compare.message.contains(directoryA.stem))
        }
    }

    @Test("An inaccessible item is `noPermission`", .enabled(if: getuid() != 0))
    func noPermission() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"locked.txt"
            let directory = folder/"locked"
            try "secret".write(to: file)
            try directory.makeDirectory()

            try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: file.path)
            try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: directory.path)
            defer {
                try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: file.path)
                try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
            }

            #expect(try thrownError { _ = try Data(at: file) }.reason == .noPermission)
            #expect(try thrownError { _ = try directory.children(range: .contentsOfDirectory) }.reason == .noPermission)
        }
    }

    @Test("An over-long name is `invalidName`")
    func invalidName() throws {
        try withTemporaryDirectory { folder in
            let item = folder/String(repeating: "a", count: 300)
            let error = try thrownError { try item.makeDirectory() }
            #expect(error.reason == .invalidName)
        }
    }

    @Test("Text the encoding cannot represent is `stringEncoding`")
    func stringEncoding() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"text.txt"
            let error = try thrownError { try "héllo ✓".write(to: file, encoding: .ascii) }
            #expect(error.reason == .stringEncoding)
            #expect(error.intent == .writing)
        }
    }

    @Test("Undecodable text is `corruptFile`, and names the file even though the system did not")
    func corruptFile() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"binary.txt"
            try Data([0xFF, 0xFE, 0xFD, 0x00, 0x80]).write(to: file)

            let error = try thrownError { _ = try String(at: file, encoding: .utf8) }
            #expect(error.reason == .corruptFile)
            #expect(error.message.contains(file.stem))

            // The system left the file out of this error, so it was completed. Everything else is as it was reported.
            let underlying = error.underlyingError as NSError
            #expect(underlying.domain == NSCocoaErrorDomain)
            #expect(underlying.code == CocoaError.fileReadCorruptFile.rawValue)
            #expect(underlying.userInfo[NSFilePathErrorKey] as? String == file.path)
        }
    }

    @Test("A missing extended attribute is `nil`, not an error")
    func missingAttribute() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"file.txt"
            try "x".write(to: file)
            #expect(try file.attributes.xattr("com.example.missing") == nil)
        }
    }


    // MARK: - Context

    @Test("The items of the call site are reported, not the system's")
    func context() throws {
        try withTemporaryDirectory { folder in
            let missing = folder/"missing.txt"
            let target = folder/"target.txt"

            let move = try thrownError { try missing.move(to: target.url) }
            #expect(move.source == missing)
            #expect(move.destination == target)
            #expect(move.intent == .writing)

            let copy = try thrownError { try missing.copy(to: target) }
            #expect(copy.source == missing)
            #expect(copy.destination == target)

            let read = try thrownError { _ = try Data(at: missing) }
            #expect(read.source == missing)
            #expect(read.destination == nil)
            #expect(read.intent == .reading)
        }
    }

    @Test("The source is a copy, not the live item")
    func sourceIsCopy() {
        let item = FinderItem(at: "/tmp/a.txt")
        let error = FileError(.noSuchFile, source: item)
        item.url = URL(filePath: "/tmp/moved.txt")

        #expect(error.source.path == "/tmp/a.txt")
        #expect(error.source !== item)
    }

    @Test("Wrapping a FileError keeps where it happened")
    func noDoubleWrap() {
        let a = FinderItem(at: "/tmp/a.txt")
        let b = FinderItem(at: "/tmp/b.txt")
        let inner = FileError(.noSuchFile, source: a, intent: .writing)
        let outer = FileError(inner, source: b)

        #expect(outer.source == a)
        #expect(outer.intent == .writing)
        #expect(outer == inner)
    }

    @Test("Equality is by reason and items")
    func equality() {
        let a = FinderItem(at: "/tmp/a.txt")
        let b = FinderItem(at: "/tmp/b.txt")

        #expect(FileError(.noSuchFile, source: a) == FileError(.noSuchFile, source: a, intent: .writing))
        #expect(FileError(.noSuchFile, source: a) != FileError(.noSuchFile, source: b))
        #expect(FileError(.noSuchFile, source: a) != FileError(.fileExists, source: a))
        #expect(FileError(.noSuchFile, source: a) != FileError(.noSuchFile, source: a, destination: b))
    }


    // MARK: - Creating

    @Test("Every reason survives being synthesized")
    func roundTrip() {
        let item = FinderItem(at: "/tmp/file.txt")

        for reason in FileError.Reason.all {
            for intent in FileError.Intent.allCases {
                let error = FileError(reason, source: item, intent: intent)
                #expect(error.reason == reason, "\(reason) / \(intent)")
                #expect(error.intent == intent)
                #expect(!error.message.isEmpty, "\(reason) / \(intent)")
            }
        }

        #expect(Set(FileError.Reason.all.map(\.rawValue)).count == FileError.Reason.all.count)
        #expect(Set(FileError.Reason.all.map { FileError($0, source: item).errorCode }).count == FileError.Reason.all.count)
    }

    @Test("Wrapping accepts any error")
    func wrapIsTotal() {
        struct Custom: Error {}
        let item = FinderItem(at: "/tmp/file.txt")

        let cases: [(error: any Error, reason: FileError.Reason)] = [
            (POSIXError(.ENOENT), .noSuchFile),
            (POSIXError(.EACCES), .noPermission),
            (Errno.noSuchFileOrDirectory, .noSuchFile),
            (Errno.fileExists, .fileExists),
            (CocoaError(.fileReadNoPermission), .noPermission),
            (CocoaError(.userCancelled), .cancelled),
            (CancellationError(), .cancelled),
            (URLError(.notConnectedToInternet), .other),
            (Custom(), .other),
        ]
        for (error, reason) in cases {
            let wrapped = FileError(error, source: item)
            #expect(wrapped.reason == reason, "\(error)")
            #expect(wrapped.source == item, "\(error)")
            #expect(!wrapped.message.isEmpty, "\(error)")
            #expect(wrapped.message != "(unknown)", "\(error)")
        }
    }

    @Test("A bare errno is reported with the file, and the intent selects the wording")
    func bareErrno() {
        let item = FinderItem(at: "/tmp/locked.txt")
        let reading = FileError(Errno.permissionDenied, source: item, intent: .reading)
        let writing = FileError(Errno.permissionDenied, source: item, intent: .writing)

        #expect(reading.reason == .noPermission)
        #expect(writing.reason == .noPermission)
        #expect(reading.errno == .permissionDenied)
        #expect(reading.message.contains("locked"))
        #expect(writing.message.contains("locked"))
        #expect(reading.message != writing.message)
    }


    // MARK: - Display

    @Test("The message rule, on constructed errors")
    func messageRule() {
        let item = FinderItem(at: "/tmp/a.txt")
        func make(_ description: String, reason: String? = nil, nested: String? = nil) -> FileError {
            var userInfo: [String : Any] = [NSLocalizedDescriptionKey: description]
            if let reason {
                userInfo[NSLocalizedFailureReasonErrorKey] = reason
            }
            if let nested {
                userInfo[NSUnderlyingErrorKey] = NSError(domain: "Nested", code: 1, userInfo: [NSLocalizedFailureReasonErrorKey: nested])
            }
            return FileError(NSError(domain: "Top", code: 1, userInfo: userInfo), source: item)
        }

        #expect(make("Top").message == "Top")
        #expect(make("Top", nested: "Nested reason").message == "Top Nested reason.")
        #expect(make("Top", nested: "Nested reason.").message == "Top Nested reason.")
        #expect(make("Top", reason: "Own reason", nested: "Nested reason").message == "Top")
        #expect(make("Top", nested: "").message == "Top")
        #expect(make("Top because of the nested reason", nested: "the nested reason").message == "Top because of the nested reason")
        #expect(make("失敗しました。", nested: "理由").message == "失敗しました。理由。")
    }

    @Test("The message is the system's text for the underlying error")
    func messageIsSystemText() throws {
        try withTemporaryDirectory { folder in
            let directory = folder/"directory"
            try directory.makeDirectory()

            let error = try thrownError { _ = try Data(at: directory) }
            let top = error.underlyingError as NSError
            #expect(error.message.hasPrefix(top.localizedDescription))
            #expect(error.localizedDescription == error.message)
            #expect(error.description == error.message)
        }
    }

    @Test("The message of real errors is what Foundation says", .enabled(if: FileErrorTests.foundationSpeaksEnglish, "The expected text is in English."))
    func messageOfRealErrors() throws {
        try withTemporaryDirectory { folder in
            let existing = folder/"existing.txt"
            let other = folder/"other.txt"
            let missing = folder/"missing.txt"
            let target = folder/"target.txt"
            let directory = folder/"directory"
            let anotherDirectory = folder/"anotherDirectory"
            let binary = folder/"binary.txt"
            try "1".write(to: existing)
            try "2".write(to: other)
            try directory.makeDirectory()
            try anotherDirectory.makeDirectory()
            try Data([0xFF, 0xFE, 0xFD, 0x00, 0x80]).write(to: binary)

            // Foundation names the folder that holds the item, which here is the temporary one.
            let folderName = folder.name
            let longName = String(repeating: "a", count: 300)

            // Errors that Foundation throws.
            try expectMessage("“missing.txt” couldn’t be removed.",
                              from: { try missing.remove() })
            try expectMessage("“missing.txt” couldn’t be moved to “\(folderName)” because either the former doesn’t exist, or the folder containing the latter doesn’t exist.",
                              from: { try missing.move(to: target.url) })
            try expectMessage("“existing.txt” couldn’t be moved to “inside” because either the former doesn’t exist, or the folder containing the latter doesn’t exist.",
                              from: { try existing.move(to: (folder/"nowhere/inside/file.txt").url) })
            try expectMessage("The file “missing.txt” couldn’t be opened because there is no such file.",
                              from: { try missing.copy(to: target) })
            try expectMessage("“existing.txt” couldn’t be copied to “\(folderName)” because an item with the same name already exists.",
                              from: { try existing.copy(to: other) })
            try expectMessage("The file “existing.txt” couldn’t be saved in the folder “\(folderName)”. The file doesn’t exist.",
                              from: { try missing.replace(existing) })
            try expectMessage("The file “missing.txt” doesn’t exist.",
                              from: { try missing.moveToTrash() })
            try expectMessage("The file “missing.txt” couldn’t be opened because there is no such file.",
                              from: { _ = try missing.contentType })
            try expectMessage("The item couldn’t be saved because the file name “\(longName)” is invalid.",
                              from: { try (folder/longName).makeDirectory() })
            try expectMessage("The file “directory” couldn’t be opened. Is a directory.",
                              from: { _ = try Data(at: directory) })
            try expectMessage("The file “binary.txt” couldn’t be opened because it isn’t in the correct format.",
                              from: { _ = try String(at: binary) })
            try expectMessage("The file couldn’t be saved using the specified text encoding.",
                              from: { try "héllo ✓".write(to: folder/"text.txt", encoding: .ascii) })

            // Errors that FinderItem throws, as Foundation would have worded them. Some come from a bare errno.
            try expectMessage("The file “missing.txt” doesn’t exist.",
                              from: { _ = try missing.children(range: .contentsOfDirectory) })
            try expectMessage("The file “missing.txt” doesn’t exist.",
                              from: { try FinderItem.updateCurrentDirectory(to: missing) })
            try expectMessage("The file “missing.txt” doesn’t exist.",
                              from: { _ = try missing.attributes.xattr("com.example.test") })
            try expectMessage("The file “existing.txt” couldn’t be saved in the folder “\(folderName)” because a file with the same name already exists.",
                              from: { try existing.makeDirectory() })
            try expectMessage("The file “directory” couldn’t be opened. Is a directory.",
                              from: { _ = try directory.contentsEqual(to: anotherDirectory) })
        }
    }

    @Test("The message of a permission error is what Foundation says", .enabled(if: FileErrorTests.foundationSpeaksEnglish && getuid() != 0, "The expected text is in English, and root is not refused."))
    func messageOfPermissionErrors() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"locked.txt"
            let directory = folder/"locked"
            try "secret".write(to: file)
            try directory.makeDirectory()

            try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: file.path)
            try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: directory.path)
            defer {
                try? FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: file.path)
                try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
            }

            try expectMessage("The file “locked.txt” couldn’t be opened because you don’t have permission to view it.",
                              from: { _ = try Data(at: file) })
            try expectMessage("The file “locked” couldn’t be opened because you don’t have permission to view it.",
                              from: { _ = try directory.children(range: .contentsOfDirectory) })
        }
    }

    @Test("Details is a tree of the operation, the items, and every error in the chain")
    func details() throws {
        try withTemporaryDirectory { folder in
            let missing = folder/"missing.txt"
            let target = folder/"target.txt"

            let error = try thrownError { try missing.move(to: target.url) }
            let details = try #require(error.details)
            #expect(details.contains("\"\(missing.path)\""))
            #expect(details.contains("\"\(target.path)\""))

            // Drawn by DetailedDescription: the operation on top, one branch per line, each nested error under its parent. No tabs.
            let lines = details.components(separatedBy: "\n")
            #expect(lines.first == "move(to:)")
            #expect(lines.contains(" ├─reason: noSuchFile"))
            #expect(lines.contains(" ├─intent: writing"))
            #expect(lines.contains(" ├─source: \"\(missing.path)\""))
            #expect(lines.contains(" ├─destination: \"\(target.path)\""))
            #expect(lines.contains(" ╰─NSCocoaErrorDomain 4"))
            #expect(lines.contains("   ╰─NSPOSIXErrorDomain 2"))
            #expect(!details.contains("\t"))
        }
    }

    @Test("Details names every error of a chain, and only shows a destination when there is one")
    func detailsOfChain() throws {
        try withTemporaryDirectory { folder in
            let directory = folder/"directory"
            try directory.makeDirectory()

            let read = try thrownError { _ = try Data(at: directory) }
            let readDetails = try #require(read.details)
            #expect(readDetails.hasPrefix("init(at:options:)\n"))
            #expect(readDetails.contains("├─reason: isDirectory"))
            #expect(readDetails.contains("╰─NSPOSIXErrorDomain 21"))
            #expect(!readDetails.contains("destination"))

            // A POSIX error is nested one level, a Cocoa error that wraps a Cocoa error two.
            let replace = try thrownError { try (folder/"missing.txt").replace(directory) }
            let replaceDetails = try #require(replace.details)
            #expect(replaceDetails.contains("╰─NSCocoaErrorDomain 512"))
            #expect(replaceDetails.contains("  ╰─NSCocoaErrorDomain 260"))
            #expect(replaceDetails.contains("    ╰─NSPOSIXErrorDomain 2"))
        }
    }

    @Test("The details of real errors are a tree of what Foundation says", .enabled(if: FileErrorTests.foundationSpeaksEnglish, "The expected text is in English."))
    func detailsOfRealErrors() throws {
        try withTemporaryDirectory { folder in
            let existing = folder/"existing.txt"
            let missing = folder/"missing.txt"
            let target = folder/"target.txt"
            let binary = folder/"binary.txt"
            try "1".write(to: existing)
            try Data([0xFF, 0xFE, 0xFD, 0x00, 0x80]).write(to: binary)
            let folderName = folder.name

            func tree(_ lines: String...) -> String {
                lines.joined(separator: "\n")
            }

            // One Foundation error with a POSIX error nested in it.
            let removed = try thrownError { try missing.remove() }
            #expect(removed.details == tree(
                "remove()",
                " ├─reason: noSuchFile",
                " ├─intent: writing",
                #" ├─source: "\#(missing.path)""#,
                " ╰─NSCocoaErrorDomain 4",
                #"   ├─description: "“missing.txt” couldn’t be removed.""#,
                #"   ├─NSFilePath: "\#(missing.path)""#,
                "   ├─NSURL: \(missing.url)",
                "   ╰─NSPOSIXErrorDomain 2",
                #"     ╰─description: "The operation couldn’t be completed. No such file or directory""#
            ))

            // Two items, and more of what Foundation put in the userInfo.
            let moved = try thrownError { try missing.move(to: target.url) }
            #expect(moved.details == tree(
                "move(to:)",
                " ├─reason: noSuchFile",
                " ├─intent: writing",
                #" ├─source: "\#(missing.path)""#,
                #" ├─destination: "\#(target.path)""#,
                " ╰─NSCocoaErrorDomain 4",
                #"   ├─description: "“missing.txt” couldn’t be moved to “\#(folderName)” because either the former doesn’t exist, or the folder containing the latter doesn’t exist.""#,
                #"   ├─NSDestinationFilePath: "\#(target.path)""#,
                #"   ├─NSFilePath: "\#(missing.path)""#,
                #"   ├─NSSourceFilePathErrorKey: "\#(missing.path)""#,
                "   ├─NSURL: \(missing.url)",
                "   ╰─NSPOSIXErrorDomain 2",
                #"     ╰─description: "The operation couldn’t be completed. No such file or directory""#
            ))

            // A Cocoa error in a Cocoa error, in a POSIX error.
            let replaced = try thrownError { try missing.replace(existing) }
            #expect(replaced.details == tree(
                "replace(_:)",
                " ├─reason: noSuchFile",
                " ├─intent: writing",
                #" ├─source: "\#(missing.path)""#,
                #" ├─destination: "\#(existing.path)""#,
                " ╰─NSCocoaErrorDomain 512",
                #"   ├─description: "The file “existing.txt” couldn’t be saved in the folder “\#(folderName)”.""#,
                "   ├─NSFileNewItemLocationKey: \(missing.url)",
                "   ├─NSFileOriginalItemLocationKey: \(existing.url)",
                "   ├─NSURL: \(existing.url)",
                "   ╰─NSCocoaErrorDomain 260",
                #"     ├─description: "The file “missing.txt” couldn’t be opened because there is no such file.""#,
                #"     ├─NSFilePath: "\#(missing.path)""#,
                "     ├─NSURL: \(missing.url)",
                "     ╰─NSPOSIXErrorDomain 2",
                #"       ╰─description: "The operation couldn’t be completed. No such file or directory""#
            ))

            // Foundation left the file out of this error, so the item of the operation was added.
            let decoded = try thrownError { _ = try String(at: binary) }
            #expect(decoded.details == tree(
                "init(at:encoding:)",
                " ├─reason: corruptFile",
                " ├─intent: reading",
                #" ├─source: "\#(binary.path)""#,
                " ╰─NSCocoaErrorDomain 259",
                #"   ├─description: "The file “binary.txt” couldn’t be opened because it isn’t in the correct format.""#,
                #"   ├─NSFilePath: "\#(binary.path)""#,
                "   ╰─NSURL: \(binary.url)"
            ))
        }
    }

    @Test("Bridging to NSError keeps the original")
    func bridging() throws {
        try withTemporaryDirectory { folder in
            let missing = folder/"missing.txt"
            let target = folder/"target.txt"

            let error = try thrownError { try missing.move(to: target.url) }
            let bridged = error as NSError
            #expect(bridged.domain == "FinderItem.FileError")
            #expect(bridged.code == error.errorCode)
            #expect(bridged.localizedDescription == error.message)
            #expect(bridged.userInfo[NSFilePathErrorKey] as? String == missing.path)
            #expect(bridged.userInfo["NSDestinationFilePath"] as? String == target.path)

            let underlying = try #require(bridged.userInfo[NSUnderlyingErrorKey] as? NSError)
            #expect(underlying.domain == NSCocoaErrorDomain)
        }
    }

    @Test("The recovery suggestion is the system's, also once bridged")
    func recoverySuggestion() {
        let item = FinderItem(at: "/tmp/file.txt")

        for reason in [FileError.Reason.noPermission, .fileExists, .noSuchFile, .other] {
            let error = FileError(reason, source: item, intent: .writing)
            #expect(error.recoverySuggestion == (error.underlyingError as NSError).localizedRecoverySuggestion, "\(reason)")
            #expect((error as NSError).localizedRecoverySuggestion == error.recoverySuggestion, "\(reason)")
        }
    }

    @Test("The item the system blames is read from the error")
    func failingItem() {
        let url = URL(filePath: "/tmp/blamed.txt")

        #expect(FileError.failingItem(in: NSError(domain: NSCocoaErrorDomain, code: 4, userInfo: [NSURLErrorKey: url]))?.path == "/tmp/blamed.txt")
        #expect(FileError.failingItem(in: NSError(domain: NSCocoaErrorDomain, code: 4, userInfo: [NSFilePathErrorKey: "/tmp/blamed.txt"]))?.path == "/tmp/blamed.txt")
        #expect(FileError.failingItem(in: NSError(domain: NSCocoaErrorDomain, code: 4)) == nil)
        #expect(FileError.failingItem(in: URLError(.cancelled)) == nil)
    }
    
    @Test("The error message from a directly initialized error")
    func directConstruction() {
        let item = FinderItem(at: "/tmp/file.txt")
        let error = FinderItem.FileError(.noSuchFile, source: item)
        #expect(error.localizedDescription == "The file “file.txt” doesn’t exist.")
    }


    // MARK: - Operations

    @Test("The widened APIs throw FileError")
    func typedThrows() throws {
        try withTemporaryDirectory { folder in
            let missing = folder/"missing.txt"
            let nowhere = folder/"missing"/"file.txt"

            // A `do` block infers `any Error`, so the type is checked by these signatures: they compile only if the calls throw `FileError`.
            func loadData() throws(FileError) { _ = try missing.load(.data) }
            func loadString() throws(FileError) { _ = try missing.load(.string) }
            func readData() throws(FileError) { _ = try Data(at: missing) }
            func readString() throws(FileError) { _ = try String(at: missing) }
            func readFileWrapper() throws(FileError) { _ = try FileWrapper(at: missing) }
            func writeData() throws(FileError) { try Data().write(to: nowhere) }
            func writeString() throws(FileError) { try "".write(to: nowhere) }
            func readAttribute() throws(FileError) { _ = try missing.attributes.xattr("com.example.test") }
            func bookmark() throws(FileError) { _ = try missing.bookmarkData() }
            func compare() throws(FileError) { _ = try missing.contentsEqual(to: folder) }
            func bundle() throws(FileError) { _ = try FinderItem.bundleItem(forResource: "definitely-missing", withExtension: "none") }
            func logs() throws(FileError) { _ = try FinderItem.logsDirectory }

            // Typed function values need the runtime of macOS 15, so the typed functions are called from untyped closures.
            let reading: [() throws -> Void] = [
                { try loadData() }, { try loadString() }, { try readData() }, { try readString() },
                { try readFileWrapper() }, { try readAttribute() }, { try bookmark() }, { try bundle() },
            ]
            for operation in reading {
                let error = try thrownError(operation)
                #expect(error.reason == .noSuchFile)
                #expect(error.intent == .reading)
            }

            let writing: [() throws -> Void] = [{ try writeData() }, { try writeString() }]
            for operation in writing {
                let error = try thrownError(operation)
                #expect(error.reason == .noSuchFile)
                #expect(error.intent == .writing)
            }

            _ = (compare, logs) // only their signatures matter
        }
    }

    @Test("The attribute updates throw FileError")
    func attributeUpdates() throws {
        try withTemporaryDirectory { folder in
            let missing = folder/"missing.txt"

            // Compile only if the update keys throw `FileError`.
            func hide() throws(FileError) { try missing.attributes.update(.isHidden, to: true) }
            func write() throws(FileError) { try missing.attributes.update(.xattr("com.example.test"), to: Data("x".utf8)) }
#if os(macOS)
            func quarantine() throws(FileError) { try missing.attributes.update(.quarantine, to: nil) }
#endif

            var operations: [() throws -> Void] = [{ try hide() }, { try write() }]
#if os(macOS)
            operations.append { try quarantine() }
#endif
            for operation in operations {
                let error = try thrownError(operation)
                #expect(error.reason == .noSuchFile)
                #expect(error.intent == .writing)
                #expect(error.source == missing)
            }
        }
    }

    @Test("Two empty files are equal")
    func emptyFiles() throws {
        try withTemporaryDirectory { folder in
            let a = folder/"a"
            let b = folder/"b"
            try a.createFile()
            try b.createFile()
            #expect(try a.contentsEqual(to: b))
        }
    }

    @Test("createFile replaces the contents, applies the attributes, and reports why it failed")
    func createFile() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"file.txt"
            try file.createFile(contents: Data("one".utf8))
            try file.createFile(contents: Data("two".utf8), attributes: [.posixPermissions: 0o600])

            #expect(try String(at: file) == "two")
            #expect(try FileManager.default.attributesOfItem(atPath: file.path)[.posixPermissions] as? Int == 0o600)

            let error = try thrownError { try (folder/"missing"/"file.txt").createFile() }
            #expect(error.reason == .noSuchFile)
            #expect(error.intent == .writing)
        }
    }

    @Test("createFile replaces an existing file atomically, so a read-only file does not stop it")
    func createFileReplaces() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"file.txt"
            try file.createFile(contents: Data("one".utf8))
            try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: file.path)
            let inode = try FileManager.default.attributesOfItem(atPath: file.path)[.systemFileNumber] as? UInt64

            try file.createFile(contents: Data("two".utf8))
            #expect(try String(at: file) == "two")
            #expect(try FileManager.default.attributesOfItem(atPath: file.path)[.systemFileNumber] as? UInt64 != inode)
        }
    }

    @Test("createFile throws when an attribute cannot be applied, after the file was written", .enabled(if: getuid() != 0, "Root may change the owner."))
    func createFileWithUnsettableAttribute() throws {
        try withTemporaryDirectory { folder in
            let file = folder/"file.txt"

            let error = try thrownError { try file.createFile(contents: Data("x".utf8), attributes: [.ownerAccountID: 0]) }
            #expect(error.intent == .writing)
            #expect(error.source == file)
            #expect(file.exists)
        }
    }

    @Test("updateCurrentDirectory changes the working directory")
    func updateCurrentDirectory() throws {
        try withTemporaryDirectory { folder in
            let previous = FinderItem.currentDirectory
            defer { try? FinderItem.updateCurrentDirectory(to: previous) }

            try FinderItem.updateCurrentDirectory(to: folder)
            let current = URL(filePath: FileManager.default.currentDirectoryPath).resolvingSymlinksInPath().path
            #expect(current == folder.url.resolvingSymlinksInPath().path)
        }
    }

}
