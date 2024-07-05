//
//  GenericError.swift
//  The FinderItem Module
//
//  Created by Vaida on 4/4/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import Foundation


/// A generic error.
///
/// All errors should conform to this protocol instead of `Error` or `LocalizedError`.
///
/// This structure is capable of
/// - Reporting error to `stdout`
/// - Display error to user using `AlertManager`
///
/// A customized error is recommended to be an `enum`.
/// ```swift
///  public enum ReadDataError: GenericError {
///     case invalidLength
///
///     public var title: String {
///         "Invalid UUID data"
///     }
///
///     public var message: String {
///         switch self {
///         case invalidLength:
///             "The length is not 16 bytes"
///         }
///     }
/// }
/// ```
///
/// ## Topics
/// ### Protocol Requirements
/// - ``title``
/// - ``message``
///
/// ### Default Implementations
/// - ``description``
/// - ``localizedDescription``
/// - ``errorDescription``
/// - ``failureReason``
public protocol _GenericError: LocalizedError, CustomStringConvertible, Equatable {
    
    /// The error description, shown as the title in `AlertManager`.
    var title: String { get }
    
    /// The failure reason, shown as the message in `AlertManager`.
    var message: String { get }
    
}


extension _GenericError {
    
    public var description: String {
        if !message.isEmpty {
            "\(title): \(message)"
        } else {
            title
        }
    }
    
    /// - Invariant: This is inherited from `GenericError.description`
    public var localizedDescription: String {
        description
    }
    
    /// - Invariant: This is inherited from ``GenericError/description``
    public var errorDescription: String? {
        description
    }
    
    /// - Invariant: This is inherited from ``GenericError/message``
    public var failureReason: String? {
        self.message
    }
    
}
