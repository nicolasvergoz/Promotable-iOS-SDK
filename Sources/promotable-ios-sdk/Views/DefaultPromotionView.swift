import SwiftUI
import UIKit

// TODO: Clean up this file and separate responsiblities
struct DefaultPromotionView: View {
  let promotion: Campaign.Promotion
  var onDismiss: () -> Void = {}
  var onAction: (URL) -> Void = { _ in }
  
  @State private var topSafeAreaInset: CGFloat = .zero
  @State private var coverYPositon: CGFloat = .zero
  @State private var coverMaxWidth: CGFloat = .zero
  @State private var dominantColor: Color? = nil
  @State private var dominantTextColor: Color = .white
  
  var body: some View {
    ZStack(alignment: .top) {
      backgroundView()
      contentScrollView()
      actionButtonView()
      closeButtonView()
    }
    .onSafeAreaInset { topSafeAreaInset = $0.top }
  }
  
  @ViewBuilder
  private func backgroundView() -> some View {
    VStack {
      if let dominantColor = dominantColor {
        dominantColor
          .frame(height: coverYPositon)
      }
      Color(uiColor: .systemBackground)
    }
    .ignoresSafeArea()
  }
  
  @ViewBuilder
  private func coverImageView() -> some View {
    // TODO: Refact this to download image once. Right now ImageView has an AsyncImage that download the image, and the task do the same to extract dominant color.
    if let coverUrl = promotion.cover?.mediaUrl {
      ImageView(coverUrl, contentMode: promotion.cover?.mediaHeight == nil ? .fit : .fill)
        .frame(maxWidth: coverMaxWidth)
        .frame(height: promotion.cover?.mediaHeight)
        .clipped()
        .overlay(alignment: .top) {
          if let dominantColor = dominantColor {
            LinearGradient(
              gradient: Gradient(colors: [dominantColor, .clear]),
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 40)
          }
        }
        .padding(.top, topSafeAreaInset)
        .onGeometryChange(for: CGFloat.self) { geometry in
          geometry.frame(in: .named("scrollContentSpace")).maxY
        } action: { newY in
          coverYPositon = newY
        }
        .task {
          // Extract dominant color from the image URL
          if let (data, _) = try? await URLSession.shared.data(from: coverUrl),
             let uiImage = UIImage(data: data) {
            if let extractedColor = DominantColorExtractor.extractDominantColor(from: uiImage, topPercentage: 0.1) {
              let color = Color(extractedColor)
              dominantColor = color
              dominantTextColor = DominantColorExtractor.contrastingTextColor(for: color)
            }
          }
        }
    }
  }
  
  @ViewBuilder
  private func contentScrollView() -> some View {
    ScrollView {
      VStack(spacing: 20) {
        coverImageView()
        topContentView()
        contentItemsView()
      }
      .onGeometryChange(for: CGFloat.self) { geometry in
        geometry.size.width
      } action: { width in
        coverMaxWidth = width
      }
      .padding(.top, promotion.cover?.mediaUrl == nil ? (topSafeAreaInset + 60) : 0)
      .padding(.bottom, 100)
    }
    .ignoresSafeArea()
    .coordinateSpace(name: "scrollContentSpace")
  }
  
  @ViewBuilder
  private func topContentView() -> some View {
    // Icon
    if let iconUrl = promotion.icon?.imageUrl {
      ImageView(iconUrl, contentMode: .fill)
        .frameSquare(120)
        .cornerRadius(16)
    }
    
    VStack(spacing: 0) {
      // Title
      if let title = promotion.title {
        Text(title)
          .font(.title)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary)
      }
      
      // Subtitle
      if let subtitle = promotion.subtitle {
        Text(subtitle)
          .font(.body)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary.opacity(0.8))
      }
    }
    
    if promotion.title != nil ||
        promotion.subtitle != nil ||
        promotion.icon?.imageUrl != nil {
      Divider().opacity(0.5)
    }
  }
  
  @ViewBuilder
  private func contentItemsView() -> some View {
    if !promotion.content.isEmpty {
      VStack(alignment: .leading, spacing: 20) {
        ForEach(promotion.content, id: \.description) { item in
          contentItemRow(item: item)
        }
      }
      .padding(.horizontal, 20)
    }
  }
  
  @ViewBuilder
  private func contentItemRow(item: Campaign.Content) -> some View {
    HStack(alignment: .top, spacing: 8) {
      if let imageUrl = item.imageURL {
        ImageView(imageUrl)
          .foregroundColor(.blue)
          .font(.system(size: 18))
      }
      Text(item.description)
        .font(.body)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  
  @ViewBuilder
  private func actionButtonView() -> some View {
    VStack {
      Spacer()
      Button(
        action: {
          onAction(promotion.action.url)
          onDismiss()
        },
        label: {
          Text(promotion.action.label)
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
  
  @ViewBuilder
  private func closeButtonView() -> some View {
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
  
  @ViewBuilder
  private func ImageView(_ url: URL?, contentMode: ContentMode = .fit) -> some View {
    if let url {
      AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
          ZStack {
            Rectangle()
              .fill(Color.gray.opacity(0.2))
            ProgressView()
          }
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: contentMode)
        case .failure(_):
          ZStack {
            Rectangle()
              .fill(Color.gray.opacity(0.2))
            Image(systemName: "exclamationmark.triangle")
              .foregroundColor(.gray)
          }
        @unknown default:
          EmptyView()
        }
      }
    } else {
      EmptyView()
    }
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

extension Campaign.Promotion {
  static let sample: Campaign.Promotion = .init(
    id: "promotion1",
    title: "Some App",
    subtitle: "Une assurance qui vous rassure",
    icon: Campaign.Image(
      imageUrl: URL(string: "https://plus.unsplash.com/premium_photo-1747810311019-a70e477281d9?q=80&w=512&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!,
      alt: "logo",
      size: .medium
    ),
    cover: Campaign.Cover(
      mediaUrl: URL(string: "https://images.unsplash.com/photo-1747760866743-97dff7918000?q=80&w=500&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
      mediaType: .image,
      mediaHeight: 300,
      alt: "banner"
    ),
    action: Campaign.Action(
      label: "Action",
      url: URL(string: "https://github.com/nicolasvergoz/vrgz/tree/mock/promotable/mock")!
    ),
    content: [
      Campaign.Content(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tristique suscipit lacinia."),
      Campaign.Content(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tristique suscipit lacinia."),
      Campaign.Content(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tristique suscipit lacinia."),
    ],
    weight: 1,
    minDisplayDuration: 30
  )
}

extension View {
  func scrollable() -> some View {
    ScrollView {
      self
    }
  }
  
  func frameSquare(_ size: Double) -> some View {
    self.frame(width: size, height: size)
  }
  
  func cornerRadius(_ radius: CGFloat) -> some View {
    self.clipShape(RoundedRectangle(cornerRadius: radius))
  }
}

extension Image {
  func frameSquare(
    _ size: Double,
    _ contentMode: ContentMode = .fit
  ) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .frame(width: size, height: size)
  }
}
