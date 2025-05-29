import SwiftUI
import UIKit

/// Main view for displaying a promotion with standardized UI
public struct DefaultPromotionView: View {
  public let promotion: Campaign.Promotion
  public var onDismiss: () -> Void = {}
  public var onAction: (URL) -> Void = { _ in }
  
  /// Creates a new DefaultPromotionView with the specified promotion and callbacks
  /// - Parameters:
  ///   - promotion: The promotion to display
  ///   - onDismiss: Callback when the view is dismissed
  ///   - onAction: Callback when the action button is tapped, with the action URL
  public init(
    promotion: Campaign.Promotion,
    onDismiss: @escaping () -> Void = {},
    onAction: @escaping (URL) -> Void = { _ in }
  ) {
    self.promotion = promotion
    self.onDismiss = onDismiss
    self.onAction = onAction
  }
  
  @State private var topSafeAreaInset: CGFloat = .zero
  @State private var coverYPosition: CGFloat = .zero
  @State private var coverMaxWidth: CGFloat = .zero
  @State private var dominantColor: Color? = nil
  @State private var dominantTextColor: Color = .white
  
  public var body: some View {
    ZStack(alignment: .top) {
      backgroundView()
      contentScrollView()
      PromotionActionButton(
        actionLabel: promotion.action.label,
        dominantColor: dominantColor,
        dominantTextColor: dominantTextColor,
        onActionTap: {
          onAction(promotion.action.url)
          onDismiss()
        }
      )
      PromotionCloseButton(onDismiss: onDismiss)
    }
    .onSafeAreaInset { topSafeAreaInset = $0.top }
  }
  
  @ViewBuilder
  private func backgroundView() -> some View {
    Color(uiColor: .systemBackground)
      .ignoresSafeArea()
  }
  
  @ViewBuilder
  private func coverImageView() -> some View {
    PromotionCoverView(
      coverUrl: promotion.cover?.mediaUrl,
      mediaHeight: promotion.cover?.mediaHeight,
      maxWidth: coverMaxWidth,
      coverYPosition: $coverYPosition,
      dominantColor: $dominantColor,
      dominantTextColor: $dominantTextColor
    )
  }
  
  @ViewBuilder
  private func contentScrollView() -> some View {
    ScrollView {
      VStack(spacing: 20) {
        coverImageView()
        PromotionHeaderView(
          title: promotion.title,
          subtitle: promotion.subtitle,
          iconUrl: promotion.icon?.imageUrl
        )
        
        PromotionContentView(contentItems: promotion.content)
          .padding(.horizontal)
      }
      .onGeometryChange(for: CGFloat.self) { geometry in
        geometry.size.width
      } action: { width in
        coverMaxWidth = width
      }
      .padding(.top, promotion.cover?.mediaUrl == nil ? (topSafeAreaInset + 60) : 0)
      .padding(.bottom, 100)
    }
    .scrollBounceBehavior(.basedOnSize)
    .ignoresSafeArea()
    .coordinateSpace(name: "scrollContentSpace")
  }
}

#Preview {
  let promotion = Campaign.Promotion.sample
  return DefaultPromotionView(
    promotion: promotion,
    onDismiss: { },
    onAction: { url in
      print("Action URL: \(url)")
    }
  )
}
