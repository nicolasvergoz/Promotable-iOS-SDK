import SwiftUI

struct DefaultPresentedPromotionView: View {
  let promotion: Campaign.Promotion
  var onDismiss: () -> Void = {}
  var onAction: (URL) -> Void = { _ in }
  
  @State private var coverHeight: CGFloat = .zero
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .top) {
        backgroundView()
        coverImageView()
        contentScrollView()
        actionButtonView()
        closeButtonView()
      }
    }
  }
  
  @ViewBuilder
  private func backgroundView() -> some View {
    Color(uiColor: .systemBackground)
      .ignoresSafeArea()
  }
  
  @ViewBuilder
  private func coverImageView() -> some View {
    if let coverUrl = promotion.cover?.mediaUrl {
      ImageView(coverUrl)
        .frame(maxWidth: .infinity)
        .onGeometrySizeChange { size in
          coverHeight = size.height
        }
        .ignoresSafeArea()
    }
  }
  
  @ViewBuilder
  private func contentScrollView() -> some View {
    ScrollView {
      VStack(spacing: 20) {
        iconView()
        titleSubtitleView()
        Divider().opacity(0.5)
        contentItemsView()
      }
      .padding(.top, promotion.cover?.mediaUrl == nil ? 40 : coverHeight - 40)
      .padding(.bottom, 50)
    }
  }
  
  @ViewBuilder
  private func iconView() -> some View {
    if let iconUrl = promotion.icon?.imageUrl {
      ImageView(iconUrl)
        .frameSquare(120)
        .cornerRadius(16)
    }
  }
  
  @ViewBuilder
  private func titleSubtitleView() -> some View {
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
          .font(.headline)
          .multilineTextAlignment(.center)
          .foregroundColor(.primary.opacity(0.8))
      }
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
      .padding(.horizontal)
      .padding(.top, 8)
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
            .background(Color.primary)
            .foregroundColor(.white)
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
      .padding(.horizontal)
    }
  }
  
  @ViewBuilder
  private func ImageView(_ url: URL?) -> some View {
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
            .scaledToFit()
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
  return DefaultPresentedPromotionView(
    promotion: promotion,
    onDismiss: { },
    onAction: { url in
      print("Action URL: \(url)")
    }
  )
}

extension Campaign.Promotion {
  static let sample: Campaign.Promotion = .init(
    id: UUID().uuidString,
    title: "Leocare",
    subtitle: "Une assurance qui vous rassure",
    icon: Campaign.Image(
      imageUrl: URL(string: "https://raw.githubusercontent.com/nicolasvergoz/vrgz/mock/promotable/mock/logo.jpg")!,
      alt: "logo",
      size: .medium
    ),
    cover: Campaign.Cover(
      mediaUrl: URL(string: "https://raw.githubusercontent.com/nicolasvergoz/vrgz/mock/promotable/mock/banner.png"),
      mediaType: .image,
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
