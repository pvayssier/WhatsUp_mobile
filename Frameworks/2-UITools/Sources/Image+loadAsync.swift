//
//  Image+loadAsync.swift
//  
//
//  Created by Paul VAYSSIER on 16/04/2024.
//

import SwiftUI

fileprivate extension UIImage {
    /// Asynchronously loads an image from a URL and returns a `UIImage`.
    /// - Parameters:
    ///   - url: The URL from which to load the image.
    /// - Returns: An optional `UIImage` loaded from the URL.
    static func loadAsync(from url: URL) async -> UIImage? {
        do {
            let data = try await URLSession.shared.data(from: url).0
            return UIImage(data: data)
        } catch {
            print("Failed to load image from URL: \(error)")
            return nil
        }
    }
}

extension Image {
    /// Creates a SwiftUI `Image` asynchronously from a URL.
    /// - Parameter url: The URL to load the image from.
    /// - Returns: An `Image` view displaying the loaded image.
    public static func loadAsync(from url: URL, defaultImage: Image) async -> Image {
        if let uiImage = await UIImage.loadAsync(from: url) {
            return Image(uiImage: uiImage)
        } else {
            return defaultImage
        }
    }
}
