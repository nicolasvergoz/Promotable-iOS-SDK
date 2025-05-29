import SwiftUI

/// Component responsible for displaying the close button
struct PromotionCloseButton: View {
  let onDismiss: () -> Void
  
  var body: some View {
    HStack {
      Spacer()
      Button(action: onDismiss) {
        Image(systemName: "xmark")
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(Color.primary)
          .padding(8)
          .background(
            Circle()
              .fill(Color(uiColor: .systemBackground))
          )
          .opacity(0.5)
      }
      .padding(.top)
      .padding(.horizontal)
    }
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
    PromotionCloseButton(onDismiss: {})
  }
}
