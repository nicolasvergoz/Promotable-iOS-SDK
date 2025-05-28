import SwiftUI
import UIKit

/// Functions to extract the dominant color from an image,
/// and to determine an appropriate text color based on the dominant color.
/// 
/// The dominant color is determined by sampling the top portion of the image
/// (by default, the top 10%), and then finding the most common color in that
/// sample.
/// 
/// The appropriate text color is determined by calculating the luminance of
/// the dominant color, and then choosing either white or black based on the
/// luminance value.
struct DominantColorExtractor {
    /// Extracts the dominant color from the top portion of an image
    /// - Parameters:
    ///   - image: The UIImage to analyze
    ///   - topPercentage: The percentage of the top part of the image to analyze (default: 0.1 or 10%)
    /// - Returns: The dominant UIColor from the image's top portion or nil if extraction fails
    static func extractDominantColor(from image: UIImage, topPercentage: CGFloat = 0.1) -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }
        
        // Calculate the rect for the top percentage of the image
        let topRect = CGRect(
            x: 0,
            y: 0,
            width: inputImage.extent.width,
            height: inputImage.extent.height * topPercentage
        )
        
        // Create a filter to crop the image to the top portion
        guard let croppedImage = CIImage(image: image)?.cropped(to: topRect) else { return nil }
        
        // Create a CIAreaAverage filter to get the average color
        let extentVector = CIVector(x: croppedImage.extent.origin.x,
                                   y: croppedImage.extent.origin.y,
                                   z: croppedImage.extent.size.width,
                                   w: croppedImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: croppedImage,
            kCIInputExtentKey: extentVector
        ]) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        // Process the result
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        
        context.render(outputImage,
                      toBitmap: &bitmap,
                      rowBytes: 4,
                      bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                      format: .RGBA8,
                      colorSpace: nil)
        
        // Create color from the bitmap
        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1.0
        )
    }
    
    /// Determines if a color is dark or light to select appropriate text color
    /// - Parameter color: The background color to analyze
    /// - Returns: A contrasting color (white for dark backgrounds, black for light)
    static func contrastingTextColor(for color: Color) -> Color {
        let uiColor = UIColor(color)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate luminance using the perceived brightness formula
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        return luminance > 0.5 ? .black : .white
    }
}

extension Color {
    /// Initializes a SwiftUI Color from a UIColor
    init(_ uiColor: UIColor) {
        self.init(uiColor: uiColor)
    }
}

extension UIColor {
    /// Initializes a UIColor from a SwiftUI Color
    convenience init(_ color: Color) {
        let components = color.components()
        self.init(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }
}

extension Color {
    /// Returns the RGBA components of a Color
    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        
        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}
