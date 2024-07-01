//
//  SwiftData.swift
//  The FinderItem Module
//
//  Created by Vaida on 7/1/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if canImport(SwiftData)
import Foundation
import SwiftData

extension FinderItem {
    
    /// The value transformer to store a `FinderItem` within `SwiftData` `Model`.
    ///
    /// This transformer bridges between ``FinderItem/bookmarkData(options:)``, `FinderItem`, and being an attribute of a `Model`.
    ///
    /// ```swift
    /// @Attribute(.externalStorage, .transformable(by: FinderItem.ValueTransformer.name))
    /// var item: FinderItem
    /// ```
    ///
    /// This transformer is designed for apps with app sandbox.
    ///
    /// ### Additional Setup
    ///
    /// To use this transformer, or any `ValueTransformer`, you must register it by defining the following in your main app
    /// ```swift
    /// init() {
    ///     FinderItem.ValueTransformer.register()
    /// }
    /// ```
    public final class ValueTransformer: Foundation.ValueTransformer {
        
        public override class func transformedValueClass() -> AnyClass {
            FinderItem.self
        }
        
        public override func transformedValue(_ value: Any?) -> Any? {
            let item = value as! FinderItem
            
            return try! withAccessingSecurityScopedResource(to: item) { source in
                try source.bookmarkData()
            }
        }
        
        public override func reverseTransformedValue(_ value: Any?) -> Any? {
            let data = (value as! Data)
            var dataIsStable = false
            return try! FinderItem(resolvingBookmarkData: data, bookmarkDataIsStale: &dataIsStable)
        }
        
        public override class func allowsReverseTransformation() -> Bool {
            true
        }
        
        /// Register the transformer.
        ///
        /// You must register any `ValueTransformer` prior to its initial invocation.
        public static func register() {
            Foundation.ValueTransformer.setValueTransformer(FinderItem.ValueTransformer(), forName: .init(name))
        }
        
        /// The name of this transformer.
        ///
        /// Please use this name to direct `SwiftData` `Model` to the correct transformer.
        public static var name: String {
            "FinderItem.ValueTransformer"
        }
    }
    
}

#endif
