//
//  CommonXAttribute.swift
//  FinderItem
//
//  Created by Vaida on 2025-07-07.
//

#if canImport(Darwin)
import Foundation


extension FinderItem {
    
    /// Inserts and replaces existing attributes.
    @inlinable
    public func insertAttribute<T>(_ attribute: CommonXAttributeKey<T>, _ value: T) throws(FinderItem.XAttributeError) {
        let plist = try! PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
        try self.insertAttribute(.xattr(attribute.name), plist)
    }
    
    /// Loads an extended attribute.
    ///
    /// > Tip:
    /// > You can use the following code to inspect all the extended attributes associated with `file`
    /// > ```swift
    /// > detailedPrint(file, configuration: .showExtendedAttributes)
    /// > ```
    @inlinable
    public func load<T>(_ attributeKey: CommonXAttributeKey<T>) throws(FinderItem.XAttributeError) -> T {
        let plist = try self.load(.xattr(attributeKey.name, as: Any?.self))! // can unwrap as long as we are sure it is a plist
        return attributeKey.parser(plist)
    }
    
    
    /// A set of predefined extended attributes.
    ///
    /// Please refer to the type properties for a set of predefined extended attributes.
    public struct CommonXAttributeKey<Value> {
        
        @usableFromInline
        let name: String
        
        @usableFromInline
        let parser: (Any) -> Value
        
        @inlinable
        init(name: String, parser: @escaping (Any) -> Value) {
            self.name = name
            self.parser = parser
        }
        
        @inlinable
        static func named(_ name: String, parser: @escaping (_ plist: Any) -> Value) -> CommonXAttributeKey {
            CommonXAttributeKey(name: name, parser: parser)
        }
        
    }
}


public extension FinderItem.CommonXAttributeKey {
    
    /// The downloaded date.
    ///
    /// - SeeAlso: ``origin``
    @inlinable
    static var dateDownloaded: FinderItem.CommonXAttributeKey<Date> {
        .named("com.apple.metadata:kMDItemDownloadedDate") { plist in
            return (plist as! NSArray)[0] as! NSDate as Date
        }
    }
    
    /// The file (download) where from.
    ///
    /// - SeeAlso: ``dateDownloaded``
    @inlinable
    static var origin: FinderItem.CommonXAttributeKey<[String]> {
        .named("com.apple.metadata:kMDItemWhereFroms") { plist in
            return (plist as! NSArray).map { $0 as! String }
        }
    }
    
    /// Finder comments on this file.
    ///
    /// - Experiment: Finder may have a hard time loading the modified comments.
    @inlinable
    static var comments: FinderItem.CommonXAttributeKey<String> {
        .named("com.apple.metadata:kMDItemFinderComment") { plist in
            return plist as! String
        }
    }
    
    /// Keywords associated with this file.
    ///
    /// - Experiment: Finder may show the keywords in a reversed order.
    @inlinable
    static var keywords: FinderItem.CommonXAttributeKey<[String]> {
        .named("com.apple.metadata:kMDItemKeywords") { plist in
            return (plist as! NSArray).map { $0 as! String }
        }
    }
    
    /// A description of the content of the resource.
    ///
    /// The description may include an abstract, table of contents, reference to a graphical representation of content or a free-text account of the content.
    @inlinable
    static var description: FinderItem.CommonXAttributeKey<String> {
        .named("com.apple.metadata:kMDItemDescription") { plist in
            return plist as! String
        }
    }
    
    /// Application used to convert the original content into it's current form.
    ///
    /// For example, a PDF file might have an encoding application set to "Distiller"
    @inlinable
    static var encodingApplications: FinderItem.CommonXAttributeKey<[String]> {
        .named("com.apple.metadata:kMDItemEncodingApplications") { plist in
            return (plist as! NSArray).map { $0 as! String }
        }
    }
}
#endif
