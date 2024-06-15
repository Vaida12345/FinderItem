//
//  FinderItem + ChildrenIterator.swift
//  The FinderItem Module
//
//  Created by Vaida on 7/25/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import CComponent
import Foundation


/// The async sequence of a `FinderItem` children.
///
/// > Tip:
/// > For advanced controls, you can use ``FinderItemChildren/Iterator/skipDescendants()`` to control the flow of ``FinderItemChildren/Iterator``.
public struct FinderItemChildren: Sequence {
    
    private let options: FinderItem.ChildrenOption
    
    private let parent: FinderItem
    
    
    public func makeIterator() -> Iterator {
        Iterator(item: self.parent, range: self.options)
    }
    
    
    internal init(options: FinderItem.ChildrenOption, parent: FinderItem) throws(FinderItem.FileError) {
        guard parent.exists else { throw FinderItem.FileError(code: .cannotRead(reason: .noSuchFile), source: parent) }
        
        self.options = options
        self.parent = parent
    }
    
    
    public typealias Element = FinderItem
    
    public struct Iterator: IteratorProtocol {
        
        private let options: FinderItem.ChildrenOption
        private let stream: UnsafeMutablePointer<FTS>
        private var current: UnsafeMutablePointer<FTSENT>? = nil
        
        
        fileprivate init(item: FinderItem, range options: FinderItem.ChildrenOption) {
            self.options = options
            
            var path = item.path
            if path.hasSuffix("/") {
                path.removeLast()
            }
            
            let _stream = FileManager.default._fileSystemRepresentation(withPath: path) { fsRep in
                let ps = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: 2)
                defer { ps.deallocate() }
                ps.initialize(to: UnsafeMutablePointer(mutating: fsRep))
                ps.advanced(by: 1).initialize(to: nil)
                return fts_cmp_open(ps, FTS_PHYSICAL | FTS_XDEV | FTS_NOCHDIR | FTS_NOSTAT)
            }!
            
            self.stream = _stream
            self.current = fts_read(stream) // consume self
        }
        
        
        public mutating func next() -> FinderItem? {
            self.current = fts_read(stream)
            guard let current else { return nil }
            
            // determine if the `current` should be skipped.
            guard (current.pointee.fts_name != Iterator.dotASCIIValue) || options.contains(.reference.withHidden) else {
                return self.next()
            }
            
            let itemName = FileManager.default.string(withFileSystemRepresentation: &current.pointee.fts_name, length: Int(current.pointee.fts_namelen))
            guard (itemName != ".DS_Store" && itemName != "Icon\r") || options.contains(.reference.withSystemHidden) else {
                return self.next()
            }
            
            
            var item: FinderItem? = nil // conditional initialized to be more efficient
            
            switch Int32(current.pointee.fts_info) {
            // directory
            case FTS_D:
                if options.contains(.contentsOfDirectory) { // skip the current dir if only care about contents of directory
                    self.skipDescendants()
                } else if let exploreDescendantsPredicate = options.exploreDescendantsPredicate { // skip if exits `exploreDescendantsPredicate`, and not explore
                    let filePath = FileManager.default.string(withFileSystemRepresentation: current.pointee.fts_path, length: Int(current.pointee.fts_pathlen))
                    item = FinderItem(_path: filePath, directoryHint: .isDirectory)
                    
                    if !exploreDescendantsPredicate(item!) {
                        self.skipDescendants()
                    }
                }
                
                fallthrough // as still need to report self
                
            // any, regular file, undefined, symbolic link, dead symbolic link, directory
            case FTS_DEFAULT, FTS_F, FTS_NSOK, FTS_SL, FTS_SLNONE, FTS_D:
                
                let filePath = FileManager.default.string(withFileSystemRepresentation: current.pointee.fts_path, length: Int(current.pointee.fts_pathlen))
                
                return item ?? FinderItem(_path: filePath, directoryHint: .notDirectory)
                
            // directory cannot read, error return, undefined
            case FTS_DNR, FTS_ERR, FTS_NS:
                break
                
            default:
                break
            }
            
            return self.next()
        }
        
        /// Skip the subdirectories of the directory in the current stream.
        public func skipDescendants() {
            if let current = current {
                fts_set(stream, current, FTS_SKIP)
            }
        }
        
        private static let dotASCIIValue = Character(".").asciiValue!
        
    }
    
}


private extension FileManager {
    
    func _fileSystemRepresentation<ResultType>(withPath path: String, _ body: (UnsafePointer<CChar>) -> ResultType) -> ResultType {
        let len = CFStringGetMaximumSizeOfFileSystemRepresentation(path as CFString)
        assert(len != kCFNotFound)
        
        let buf = UnsafeMutablePointer<CChar>.allocate(capacity: len)
        buf.initialize(repeating: 0, count: len)
        defer {
            buf.deinitialize(count: len)
            buf.deallocate()
        }
        
        assert(CFStringGetFileSystemRepresentation(path as NSString, buf, len))
        
        return body(buf)
    }
    
}
