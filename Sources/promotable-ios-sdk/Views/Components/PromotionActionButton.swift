import SwiftUI

/// Component responsible for displaying the action button
struct PromotionActionButton: View {
  let actionLabel: String
  let dominantColor: Color?
  let dominantTextColor: Color
  let onActionTap: () -> Void
  
  var body: some View {
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
