import SwiftUI

extension View {
  // TODO: Doc comment
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
