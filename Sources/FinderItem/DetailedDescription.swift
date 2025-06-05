//
//  DetailedDescription.swift
//  FinderItem
//
//  Created by Vaida on 2025-05-15.
//

import DetailedDescription


extension FinderItem: DetailedStringConvertibleWithConfiguration {
    
    /// The description of the `item`'s hierarchy.
    public func detailedDescription(
        using descriptor: DetailedDescription.Descriptor<FinderItem>,
        configuration: DescriptionConfiguration
    ) -> any DescriptionBlockProtocol {
        let fileSize = configuration.contains(.showFileSize) ? self.fileSize.map { " [\(Int64($0), format: .byteCount(style: .file))]" } ?? "" : ""
        
        return if self.isDirectory,
            let children = try? self.children(range: .contentsOfDirectory.withHidden) {
            descriptor.sequence(self.name + fileSize, of: children, configuration: configuration)
                .hideIndex()
        } else {
            descriptor.constant(self.name + fileSize)
        }
    }
    
    
    public struct DescriptionConfiguration: Initializable, OptionSet, Sendable {
        
        public var rawValue: UInt64
        
        @inlinable
        public init() {
            self.init(rawValue: 0)
        }
        
        @inlinable
        public init(rawValue: UInt64) {
            self.rawValue = rawValue
        }
        
        /// The optional to append the file size after file name.
        public static let showFileSize = DescriptionConfiguration(rawValue: 1 << 0)
    }
    
}
