import SwiftUI
import UIKit

// Extension for common view modifiers
extension View {
  /// Makes the view scrollable
  func scrollable() -> some View {
    ScrollView {
      self
    }
  }
  
  /// Sets both width and height to create a square frame
  func frameSquare(_ size: Double) -> some View {
    self.frame(width: size, height: size)
  }
  
  /// Applies corner radius with a rounded rectangle clip shape
  func cornerRadius(_ radius: CGFloat) -> some View {
    self.clipShape(RoundedRectangle(cornerRadius: radius))
  }
  
  /// Monitors safe area insets and reports changes via a callback
  /// - Parameter action: Handler that receives updated EdgeInsets
  /// - Returns: Modified view with safe area monitoring
  func onSafeAreaInset(_ action: @escaping (EdgeInsets) -> Void) -> some View {
    background(
      GeometryReader { proxy in
        Color.clear
          .onAppear {
            action(proxy.safeAreaInsets)
          }
          .onChange(of: proxy.safeAreaInsets) { _, newValue in
            action(newValue)
          }
      }
    )
  }
}

extension Image {
  /// Convenience modifier to create a square image with specified content mode
  func frameSquare(
    _ size: Double,
    _ contentMode: ContentMode = .fit
  ) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .frame(width: size, height: size)
  }
}

// Preference keys
struct GeometryPreferenceKey<T: Equatable>: PreferenceKey {
  static var defaultValue: T? { nil }
  
  static func reduce(value: inout T?, nextValue: () -> T?) {
    value = nextValue() ?? value
  }
}

struct SafeAreaPreferenceKey: PreferenceKey {
  static let defaultValue: EdgeInsets = EdgeInsets()
  
  static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
    value = nextValue()
  }
}

extension Color {
  /// Initializes a SwiftUI Color from a hex string (e.g., "#FF5733" or "FF5733")
  /// - Parameter hex: A hex color string, with or without the leading '#'
  /// - Returns: A Color object or nil if the hex string is invalid
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
      return nil
    }
    
    let r, g, b: Double
    
    switch hexSanitized.count {
    case 6: // RGB (24-bit)
      r = Double((rgb & 0xFF0000) >> 16) / 255.0
      g = Double((rgb & 0x00FF00) >> 8) / 255.0
      b = Double(rgb & 0x0000FF) / 255.0
    case 8: // ARGB (32-bit)
      // Ignore alpha channel for our purpose
      r = Double((rgb & 0x00FF0000) >> 16) / 255.0
      g = Double((rgb & 0x0000FF00) >> 8) / 255.0
      b = Double(rgb & 0x000000FF) / 255.0
    default:
      return nil
    }
    
    self.init(red: r, green: g, blue: b)
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
