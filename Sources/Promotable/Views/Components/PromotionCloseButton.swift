import SwiftUI

/// Component responsible for displaying the close button
public struct PromotionCloseButton: View {
  public let onDismiss: () -> Void
  
  /// Creates a new PromotionCloseButton with the specified dismissal action
  /// - Parameter onDismiss: Callback when the close button is tapped
  public init(onDismiss: @escaping () -> Void) {
    self.onDismiss = onDismiss
  }
  
  public var body: some View {
    HStack {
      Spacer()
      Button(action: onDismiss) {
        Image(systemName: "xmark")
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(Color.secondary)
          .padding(8)
          .background(
            Circle()
              .fill(Color(uiColor: .systemBackground))
              .opacity(0.8)
          )
      }
      .padding(.horizontal)
    }
  }
}

#Preview {
  ZStack(alignment: .top) {
    Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
    PromotionCloseButton(onDismiss: {})
  }
}
