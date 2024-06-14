//
//  FinderItem + Children.swift
//  The FinderItem Module
//
//  Created by Vaida on 5/1/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


public extension FinderItem {
    
    /// Returns the sorted children of the folder.
    ///
    /// - Warning: The contents of packages are ignored.
    ///
    /// - Returns: If `self` is not a folder, the returned value is `[]`.
    ///
    /// - Warning: For bookmarked or user selected files, you might need to consider the security scope for both macOS and iOS.
    ///
    /// - Parameters:
    ///   - range: the range for finding children.
    @inline(__always)
    func children(range: ChildrenOption) throws -> FinderItemChildren {
        try FinderItemChildren(options: range, parent: self)
    }
    
    
    /// Options for getting the ``children(range:)`` of the item.
    ///
    /// > Example:
    /// >
    /// > Accessing the all the children and hidden files of ``desktopDirectory``.
    /// > ```swift
    /// > desktopDirectory.children(range: .enumeration.withHidden)
    /// > ```
    ///
    /// - SeeAlso: ``ChildrenOption/Additional``
    @dynamicMemberLookup
    struct ChildrenOption: Equatable, Sendable {
        
        private let rawValue: UInt8
        
        internal let exploreDescendantsPredicate: (@Sendable (FinderItem) -> Bool)?
        
        // Public callable attributes
        /// Performs a shallow search of the folder.
        ///
        /// - Tip: Unless ``Additional/withHidden``, hidden files, directories and their children are ignored.
        public static let contentsOfDirectory = ChildrenOption(rawValue: 1 << 0)
        
        /// Performs a deep enumeration of the folder.
        ///
        /// This method would enumerate covering all files and folders.
        ///
        /// - Tip: Unless ``Additional/withHidden``, hidden files, directories and their children are ignored.
        public static let enumeration = ChildrenOption(rawValue: 1 << 1)
        
        /// Performs the same as ``contentsOfDirectory``.``Additional/withSystemHidden``, and would only explore the contents of a subfolder when it satisfies the `predicate`.
        public static func exploreDescendants(on predicate: @escaping @Sendable (FinderItem) -> Bool) -> ChildrenOption {
            ChildrenOption(rawValue: 1 << 4, exploreDescendantsPredicate: predicate)
        }
        
        // Backend support attributes
        /// Performs a shallow search of the folder, with the hidden
        @available(*, deprecated, renamed: "contentsOfDirectory.withHidden")
        public static let contentsOfDirectoryWithHidden = contentsOfDirectory.withHidden
        
        /// Performs a deep enumeration of the folder, with the hidden files.
        @available(*, deprecated, renamed: "enumeration.withHidden")
        public static let enumerationWithHidden = enumeration.withHidden
        
        fileprivate init(rawValue: UInt8, exploreDescendantsPredicate: (@Sendable (FinderItem) -> Bool)? = nil) {
            self.rawValue = rawValue
            self.exploreDescendantsPredicate = exploreDescendantsPredicate
        }
        
        internal static let reference = Additional()
        
        /// A read subscript to a keyPath of `Source`.
        ///
        /// - Note: The type needs to conform to `@dynamicMemberLookup`.
        public subscript(dynamicMember keyPath: KeyPath<Additional, ChildrenOption>) -> ChildrenOption {
            ChildrenOption(rawValue: self.rawValue | ChildrenOption.reference[keyPath: keyPath].rawValue, exploreDescendantsPredicate: self.exploreDescendantsPredicate)
        }
        
        internal func contains(_ other: ChildrenOption) -> Bool {
            self.rawValue | other.rawValue == self.rawValue
        }
        
        public static func == (lhs: ChildrenOption, rhs: ChildrenOption) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
        
        /// Additional instructions to specify the range of retrieving children.
        ///
        /// - SeeAlso: ``ChildrenOption``
        public struct Additional: Sendable {
            
            /// The option to include hidden files.
            ///
            /// - Remark: Without this option, hidden files, folders, and their contents are excluded, which is default.
            public let withHidden: ChildrenOption = ChildrenOption(rawValue: 1 << 2)
            
            /// The option to include hidden files, and system hidden files.
            ///
            /// - Remark: This would include ``withHidden``, along side with `.DS_Store` and `Icon\r`.
            public let withSystemHidden: ChildrenOption = ChildrenOption(rawValue: 1 << 3 | 1 << 2)
            
            fileprivate init() { }
        }
    }
    
}
