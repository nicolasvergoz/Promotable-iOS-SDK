import SwiftUI

extension View {
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
          .onChange(of: proxy.safeAreaInsets) { newValue in
            action(newValue)
          }
      }
    )
  }
}
