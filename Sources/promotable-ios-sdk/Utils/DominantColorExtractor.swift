import SwiftUI
import UIKit

/// Functions to extract the dominant color from an image,
/// and to determine an appropriate text color based on the dominant color.
///
/// The dominant color is determined by analyzing the entire image and finding
/// the most common color.
///
/// The appropriate text color is determined by calculating the luminance of
/// the dominant color, and then choosing either white or black based on the
/// luminance value.
struct DominantColorExtractor {
  /// Extracts the dominant color from an image
  /// - Parameter image: The UIImage to analyze
  /// - Returns: The dominant UIColor from the image or nil if extraction fails
  static func extractDominantColor(from image: UIImage) -> UIColor? {
    guard let inputImage = CIImage(image: image) else { return nil }
    
    // Use the entire image
    let fullRect = inputImage.extent
    
    // No need to crop the image as we're analyzing the entire image
    let croppedImage = inputImage
    
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
