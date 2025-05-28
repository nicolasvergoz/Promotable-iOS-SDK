import SwiftUI

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
