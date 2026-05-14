//
//  Attributes + Permissions.swift
//  FinderItem
//
//  Created by Vaida on 2026-05-14.
//

import Foundation


extension FinderItem.Attributes {
    
    /// The file’s Posix permissions.
    @inlinable
    public var permissions: Permissions? {
        guard let value = self._fm_attributes[.posixPermissions] as? UInt else { return nil }
        return Permissions(uint: value)
    }
    
    
    /// A type-safe representation of POSIX permission bits.
    ///
    /// This structure models owner/group/other access flags and special mode bits.
    public struct Permissions {
        
        /// Access permissions for one identity class (owner, group, or others).
        public struct Access: Sendable, Equatable {
            
            /// Whether read permission is granted.
            public var read: Bool
            
            /// Whether write permission is granted.
            public var write: Bool
            
            /// Whether execute/search permission is granted.
            public var execute: Bool
            
            
            /// Creates an access value from explicit read/write/execute flags.
            @inlinable
            init(read: Bool = false, write: Bool = false, execute: Bool = false) {
                self.read = read
                self.write = write
                self.execute = execute
            }
        }
        
        /// Access permissions for file owner.
        public var owner: Access
        
        /// Access permissions for file group.
        public var group: Access
        
        /// Access permissions for all other users.
        public var others: Access
        
        /// The set-user-ID special bit.
        public var setUserID: Bool
        
        /// The set-group-ID special bit.
        public var setGroupID: Bool
        
        /// The sticky special bit.
        public var sticky: Bool
        
        
        /// Creates permissions from typed access and special-bit values.
        @inlinable
        init(
            owner: Access = .init(),
            group: Access = .init(),
            others: Access = .init(),
            setUserID: Bool = false,
            setGroupID: Bool = false,
            sticky: Bool = false
        ) {
            self.owner = owner
            self.group = group
            self.others = others
            self.setUserID = setUserID
            self.setGroupID = setGroupID
            self.sticky = sticky
        }
        
        /// Creates permissions by decoding POSIX mode bits.
        ///
        /// The value is interpreted as an octal mode such as `0o755` or `0o4755`.
        @inlinable
        public init(rawValue: UInt16) {
            self.owner = .init(
                read: rawValue & 0o400 != 0,
                write: rawValue & 0o200 != 0,
                execute: rawValue & 0o100 != 0
            )
            
            self.group = .init(
                read: rawValue & 0o040 != 0,
                write: rawValue & 0o020 != 0,
                execute: rawValue & 0o010 != 0
            )
            
            self.others = .init(
                read: rawValue & 0o004 != 0,
                write: rawValue & 0o002 != 0,
                execute: rawValue & 0o001 != 0
            )
            
            self.setUserID = rawValue & 0o4000 != 0
            self.setGroupID = rawValue & 0o2000 != 0
            self.sticky = rawValue & 0o1000 != 0
        }
        
        /// Internal bridge from `FileManager` POSIX permission values.
        @inlinable
        init(uint: UInt) {
            self.init(rawValue: UInt16(uint & 0o7777))
        }
        
        /// Encodes this value into POSIX mode bits.
        ///
        /// The result can be interpreted as an octal mode such as `0o755`.
        public var rawValue: UInt16 {
            var result: UInt16 = 0
            
            if owner.read { result |= 0o400 }
            if owner.write { result |= 0o200 }
            if owner.execute { result |= 0o100 }
            
            if group.read { result |= 0o040 }
            if group.write { result |= 0o020 }
            if group.execute { result |= 0o010 }
            
            if others.read { result |= 0o004 }
            if others.write { result |= 0o002 }
            if others.execute { result |= 0o001 }
            
            if setUserID { result |= 0o4000 }
            if setGroupID { result |= 0o2000 }
            if sticky { result |= 0o1000 }
            
            return result
        }
    }
    
}
