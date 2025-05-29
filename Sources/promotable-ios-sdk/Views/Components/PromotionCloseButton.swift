import SwiftUI

/// Component responsible for displaying the close button
struct PromotionCloseButton: View {
  let onDismiss: () -> Void
  
  var body: some View {
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
