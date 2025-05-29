import SwiftUI

/// Component responsible for displaying the action button
public struct PromotionActionButton: View {
  public let actionLabel: String
  public let accentColor: Color?
  public let accentContrastColor: Color
  public let onActionTap: () -> Void
  
  /// Creates a new PromotionActionButton with the specified parameters
  /// - Parameters:
  ///   - actionLabel: The text to display on the button
  ///   - accentColor: The background color of the button (uses primary color if nil)
  ///   - accentContrastColor: The text color of the button
  ///   - onActionTap: Callback when the button is tapped
  public init(
    actionLabel: String,
    accentColor: Color?,
    accentContrastColor: Color,
    onActionTap: @escaping () -> Void
  ) {
    self.actionLabel = actionLabel
    self.accentColor = accentColor
    self.accentContrastColor = accentContrastColor
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
            .background(accentColor ?? Color.primary)
            .foregroundColor(accentContrastColor)
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
      accentColor: .blue,
      accentContrastColor: .white,
      onActionTap: {}
    )
  }
  .frame(height: 300)
}
