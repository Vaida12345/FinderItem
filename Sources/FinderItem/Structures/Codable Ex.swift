//
//  Codable Extensions.swift
//  The Stratum Module - Extended Functionalities
//
//  Created by Vaida on 8/18/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


public extension Data {
    
    /// Decodes the data to the expected `type`.
    ///
    /// - Parameters:
    ///   - type: The type the file represents.
    ///   - format: The decoder to be used.
    ///
    /// - Returns: The contents decoded from `source`.
    @inlinable
    func decoded<T>(type: T.Type, format: CodingFormat) throws -> T where T: Decodable {
        if [5, 4, 3].contains(format.rawValue) {
            let decoder = PropertyListDecoder()
            return try decoder.decode(T.self, from: self)
        } else {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: self)
        }
    }
    
    /// The encoder and output format for archiving data.
    ///
    /// - Experiment: The `binary` format of ``CodingFormat/plist`` encoder offers the fastest coding.
    ///
    /// > Example:
    /// >
    /// > The format which uses the Property List Coder with binary format.
    /// > ```swift
    /// > let format: CodingFormat = .plist.binary
    /// > ```
    class CodingFormat {
        
        @usableFromInline
        internal let rawValue: UInt8
        
        fileprivate init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        /// Indicates the use of `JSONEncoder`.
        ///
        /// - Remark: The default format used is `prettyPrinted`.
        ///
        /// - Parameters:
        ///   - format: The output format which determine the readability, size, and element order of an encoded JSON object.
        ///
        /// - Returns: A json encoder with the format selected.
        public static var json: JSONCodingFormat { JSONCodingFormat(rawValue: 0) }
        
        /// Indicates the use of `PropertyListEncoder`.
        ///
        /// - Remark: The default format used is `binary`.
        ///
        /// - Parameters:
        ///   - format: The specified property list serialization format.
        ///
        /// - Returns: A plist encoder with the format selected.
        public static var plist: PropertyListCodingFormat { PropertyListCodingFormat(rawValue: 5) }
    }
    
    /// The JavaScript Object Notation coding format.
    final class JSONCodingFormat: CodingFormat {
        
        /// The output formatting option that uses ample white space and indentation to make output easy to read.
        public let prettyPrinted = CodingFormat(rawValue: 0)
        
        /// The output formatting option that sorts keys in lexicographic order.
        public let sortedKeys = CodingFormat(rawValue: 1)
        
        /// Specifies that the output doesn’t prefix slash characters with escape characters.
        public let withoutEscapingSlashes = CodingFormat(rawValue: 2)
        
    }
    
    /// The Property List coding format by Apple.
    final class PropertyListCodingFormat: CodingFormat {
        
        /// Specifies the ASCII property list format inherited from the OpenStep APIs.
        public let openStep = CodingFormat(rawValue: 3)
        
        /// Specifies the XML property list format.
        public let xml = CodingFormat(rawValue: 4)
        
        /// Specifies the binary property list format.
        public let binary = CodingFormat(rawValue: 5)
        
    }
    
}


public extension Decodable {
    
    /// Initialize from `source` which is of `format`.
    ///
    /// - Parameters:
    ///   - data: The source data.
    ///   - format: The format in which the data is.
    @inlinable
    init(data: Data, format: Data.CodingFormat) throws {
        self = try data.decoded(type: Self.self, format: format)
    }
    
    /// Initialize from `source` which is of `format`.
    ///
    /// - Parameters:
    ///   - source: The location of source data.
    ///   - format: The format in which the data is.
    @inlinable
    init(at source: FinderItem, format: Data.CodingFormat) throws {
        self = try Data(at: source).decoded(type: Self.self, format: format)
    }
    
}


public extension Encodable {
    
    /// Encodes `self` to data using the `format`.
    ///
    /// - Parameters:
    ///   - format: The format used to encode data.
    @inlinable
    func data(using format: Data.CodingFormat) throws -> Data {
        switch format.rawValue {
        case 5:
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            return try encoder.encode(self)
            
        case 4:
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            return try encoder.encode(self)
            
        case 3:
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .openStep
            return try encoder.encode(self)
            
        case 0:
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(self)
            
        case 1:
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            return try encoder.encode(self)
            
        case 2:
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            return try encoder.encode(self)
        default:
            fatalError("Unknown format: \(format)")
        }
    }
    
    /// Write the structure to disk using the given `format`.
    ///
    /// - Parameters:
    ///   - destination: The destination file location.
    ///   - format: The format used.
    @available(*, deprecated, renamed: "write(to:format:)", message: "Use the new signature to match the loading arguments")
    @inlinable
    func write(to destination: FinderItem, using format: Data.CodingFormat) throws {
        try self.data(using: format).write(to: destination)
    }
    
    /// Write the structure to disk using the given `format`.
    ///
    /// - Parameters:
    ///   - destination: The destination file location.
    ///   - format: The format used.
    @inlinable
    func write(to destination: FinderItem, format: Data.CodingFormat) throws {
        try self.data(using: format).write(to: destination)
    }
    
}


extension NSSecureCoding {
    
    /// The data for this instance using `NSKeyedArchiver`.
    public func data() throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }
    
    /// Decode given data using `NSKeyedUnarchiver`
    public static func decoded(from data: Data) throws -> Self where Self: NSObject {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        guard let result = try unarchiver.decodeTopLevelObject(of: Self.self, forKey: NSKeyedArchiveRootObjectKey) else { throw CocoaError(.coderReadCorrupt) }
        return result
    }
    
}
