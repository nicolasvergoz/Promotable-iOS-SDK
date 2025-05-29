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
  @State private var accentColor: Color? = nil
  @State private var accentContrastColor: Color = .white
  
  @State private var coverImage: UIImage? = nil
  @State private var iconImage: UIImage? = nil
  
  public var body: some View {
    ZStack(alignment: .top) {
      backgroundView()
      contentScrollView()
      PromotionActionButton(
        actionLabel: promotion.action.label,
        accentColor: determineAccentColor(),
        accentContrastColor: accentContrastColor,
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
      accentColor: $accentColor,
      accentContrastColor: $accentContrastColor
    )
    .task {
      // Load cover image for color extraction if available
      if let coverUrl = promotion.cover?.mediaUrl {
        await loadImage(from: coverUrl, into: $coverImage)
      }
    }
  }
  
  /// Loads an image from a URL and assigns it to a binding
  private func loadImage(from url: URL, into binding: Binding<UIImage?>) async {
    if let (data, _) = try? await URLSession.shared.data(from: url),
       let uiImage = UIImage(data: data) {
      binding.wrappedValue = uiImage
    }
  }
  
  /// Determines the accent color using a cascading strategy and updates the contrast color accordingly:
  /// - First, use the explicitly provided background color if available
  /// - Otherwise, extract the dominant color from the cover image if available
  /// - Otherwise, extract the dominant color from the icon if available
  /// - Finally, fall back to the system background color
  private func determineAccentColor() -> Color {
    // Strategy 1: Use explicitly provided background color if available
    if let hexColor = promotion.action.backgroundColor, !hexColor.isEmpty {
      let color = Color(hex: hexColor) ?? Color(UIColor.systemBackground)
      accentContrastColor = DominantColorExtractor.contrastingTextColor(for: color)
      return color
    }
    
    // Strategy 2: Extract dominant color from cover image if available
    if let coverImg = coverImage, let dominantColor = DominantColorExtractor.extractDominantColor(from: coverImg) {
      let color = Color(dominantColor)
      accentContrastColor = DominantColorExtractor.contrastingTextColor(for: color)
      return color
    }
    
    // Strategy 3: Extract dominant color from icon image if available
    if let iconImg = iconImage, let dominantColor = DominantColorExtractor.extractDominantColor(from: iconImg) {
      let color = Color(dominantColor)
      accentContrastColor = DominantColorExtractor.contrastingTextColor(for: color)
      return color
    }
    
    // Strategy 4: Fall back to system background color
    let color = Color.primary
    accentContrastColor = DominantColorExtractor.contrastingTextColor(for: color)
    return color
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
        .task {
          // Load icon image for color extraction if available
          if let iconUrl = promotion.icon?.imageUrl {
            await loadImage(from: iconUrl, into: $iconImage)
          }
        }
        
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
  // Create a sample promotion with a custom action background color
  var promotion = Campaign.Promotion.sample
  // Set a custom background color for the action button in the sample
  promotion = Campaign.Promotion(
    id: promotion.id,
    title: promotion.title,
    subtitle: promotion.subtitle,
    icon: promotion.icon,
    cover: promotion.cover,
    action: Campaign.Action(
      label: promotion.action.label,
      url: promotion.action.url,
      backgroundColor: "#FF5733" // Bright orange color
    ),
    content: promotion.content,
    weight: promotion.weight,
    minDisplayDuration: promotion.minDisplayDuration
  )
  
  return DefaultPromotionView(
    promotion: promotion,
    onDismiss: { },
    onAction: { url in
      print("Action URL: \(url)")
    }
  )
}
