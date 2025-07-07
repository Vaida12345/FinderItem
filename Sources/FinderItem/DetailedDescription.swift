//
//  DetailedDescription.swift
//  FinderItem
//
//  Created by Vaida on 2025-05-15.
//

import Foundation
import DetailedDescription


extension FinderItem: DetailedStringConvertibleWithConfiguration {
    
    /// The description of the `item`'s hierarchy.
    public func detailedDescription(
        using descriptor: DetailedDescription.Descriptor<FinderItem>,
        configuration: DescriptionConfiguration
    ) -> any DescriptionBlockProtocol {
        let fileSize = configuration.contains(.showFileSize) ? (try? self.load(.fileSize).map { " [\(Int64($0), format: .byteCount(style: .file))]" }) ?? "" : ""
        
        return if self.isDirectory,
            let children = try? self.children(range: .contentsOfDirectory.withHidden) {
            if configuration.contains(.showExtendedAttributes) {
                descriptor.container(self.name + fileSize) {
                    if let attributes = try? self.load(.xattr) {
                        descriptor.container("attributes") {
                            descriptor.forEach(attributes) { name in
                                if let string = try? self.load(.xattr(name, as: String?.self)) {
                                    descriptor.value(name, of: string)
                                } else if let plist = try? self.load(.xattr(name, as: Any?.self)) {
                                    descriptor.value(name, of: plist)
                                } else {
                                    descriptor.constant("\(name): <binary>")
                                }
                            }
                        }
                    }
                    
                    descriptor.sequence("children", of: children, configuration: configuration)
                        .hideIndex()
                }
            } else {
                descriptor.sequence(self.name + fileSize, of: children, configuration: configuration)
                    .hideIndex()
            }
        } else {
            if configuration.contains(.showExtendedAttributes) {
                descriptor.container(self.name + fileSize) {
                    if let attributes = try? self.load(.xattr) {
                        descriptor.forEach(attributes) { name in
                            if let string = try? self.load(.xattr(name, as: String?.self)) {
                                descriptor.value(name, of: string)
                            } else if let plist = try? self.load(.xattr(name, as: Any?.self)) {
                                descriptor.value(name, of: plist)
                            } else {
                                descriptor.constant("\(name): <binary>")
                            }
                        }
                    }
                }
            } else {
                descriptor.constant(self.name + fileSize)
            }
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
        
        /// The optional to show the extended attributes associated with `self`.
        ///
        /// - Tip: To obtain the attribute, see ``FinderItem/XAttributeKey/xattr(_:)``.
        public static let showExtendedAttributes = DescriptionConfiguration(rawValue: 1 << 1)
    }
    
}
