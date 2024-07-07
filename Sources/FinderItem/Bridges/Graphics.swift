//
//  FI + GraphicsKit.swift
//  The FinderItem Module
//
//  Created by Vaida on 6/15/24.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

import GraphicsKit
import SwiftUI


public extension View {
    
    /// Render the view to given destination.
    ///
    /// ## Rendering
    /// The following components will cause the result to be rendered in `TIFF`!
    /// - `material`
    ///
    /// - Parameters:
    ///   - destination: The destination
    ///   - format: The resulting format
    ///   - scale: The scale to the view
    @inlinable
    @MainActor
    func render(to destination: FinderItem, format: NativeImage.ImageFormatOption = .pdf, scale: Double = 1) {
        self.render(to: destination.url, format: format, scale: scale)
    }
}


public extension NativeImage {
    
    /// Write a `NativeImage` as in the format of `option` to the `destination`.
    ///
    /// - Parameters:
    ///   - destination: The `FinderItem` representing the path to save the image.
    ///   - format: The format of the image, pass `nil` to auto infer from the extension name of `destination`.
    ///   - quality: The image compression quality.
    func write(to destination: FinderItem, format: ImageFormatOption? = nil, quality: Double = 1) throws {
        try self.write(to: destination.url, format: format, quality: quality)
    }
    
}


public extension CGImage {
    
    /// Write a `CGImage` as in the format of `option` to the `destination`.
    ///
    /// A `quality` value of 1.0 specifies to use lossless compression if destination format supports it. A value of 0.0 implies to use maximum compression.
    ///
    /// - Parameters:
    ///   - destination: The `FinderItem` representing the path to save the image.
    ///   - format: The format of the image, pass `nil` to auto infer from the extension name of `destination`.
    ///   - quality: The image compression quality.
    func write(to destination: FinderItem, format: NativeImage.ImageFormatOption? = nil, quality: CGFloat = 1) throws {
        do {
            try self.write(to: destination.url, format: format, quality: quality)
        } catch {
            throw try FinderItem.FileError.parse(orThrow: error)
        }
    }
    
}

