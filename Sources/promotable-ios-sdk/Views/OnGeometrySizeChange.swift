import SwiftUI

struct GeometrySizePreferenceKey: PreferenceKey {
  static let defaultValue: CGSize = .zero
  
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct OnGeometrySizeChange: ViewModifier {
  let action: (CGSize) -> Void
  
  init(perform action: @escaping (CGSize) -> Void) {
    self.action = action
  }
  
  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { proxy in
          Color
            .clear
            .preference(key: GeometrySizePreferenceKey.self, value: proxy.size)
            .onPreferenceChange(GeometrySizePreferenceKey.self) { size in
              Task { @MainActor in
                action(size)
              }
            }
        }
      )
  }
}

extension View {
  func onGeometrySizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
    modifier(OnGeometrySizeChange(perform: action))
  }
}
