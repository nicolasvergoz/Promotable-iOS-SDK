import SwiftUI

/// Component responsible for displaying the action button
public struct PromotionActionButton: View {
  public let actionLabel: String
  public let dominantColor: Color?
  public let dominantTextColor: Color
  public let onActionTap: () -> Void
  
  /// Creates a new PromotionActionButton with the specified parameters
  /// - Parameters:
  ///   - actionLabel: The text to display on the button
  ///   - dominantColor: The background color of the button (uses primary color if nil)
  ///   - dominantTextColor: The text color of the button
  ///   - onActionTap: Callback when the button is tapped
  public init(
    actionLabel: String,
    dominantColor: Color?,
    dominantTextColor: Color,
    onActionTap: @escaping () -> Void
  ) {
    self.actionLabel = actionLabel
    self.dominantColor = dominantColor
    self.dominantTextColor = dominantTextColor
    self.onActionTap = onActionTap
  }
  
  public var body: some View {
    VStack {
      Spacer()
      Button(
        action: onActionTap,
        label: {
          Text(actionLabel)
            .font(.headline)
            .fontWeight(.semibold)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(dominantColor ?? Color.primary)
            .foregroundColor(dominantTextColor)
            .cornerRadius(24)
        }
      )
      .padding(.horizontal)
    }
  }
}

#Preview {
  ZStack {
    Color.white.edgesIgnoringSafeArea(.all)
    
    PromotionActionButton(
      actionLabel: "Get Started",
      dominantColor: .blue,
      dominantTextColor: .white,
      onActionTap: {}
    )
  }
  .frame(height: 300)
}
