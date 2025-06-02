import SwiftUI

/// Component responsible for displaying the cover image and extracting its dominant color
public struct PromotionCoverView: View {
  public let coverUrl: URL?
  public let mediaHeight: CGFloat?
  public let maxWidth: CGFloat
  
  @Binding public var coverYPosition: CGFloat
  @Binding public var accentColor: Color?
  @Binding public var accentContrastColor: Color
  
  /// Creates a new PromotionCoverView with the specified parameters
  /// - Parameters:
  ///   - coverUrl: URL of the cover image
  ///   - mediaHeight: Optional fixed height for the cover image
  ///   - maxWidth: Maximum width for the cover image
  ///   - coverYPosition: Binding for tracking the Y position of the cover
  ///   - accentColor: Binding for storing the extracted accent color
  ///   - accentContrastColor: Binding for storing the text color that contrasts with the accent color
  public init(
    coverUrl: URL?,
    mediaHeight: CGFloat?,
    maxWidth: CGFloat,
    coverYPosition: Binding<CGFloat>,
    accentColor: Binding<Color?>,
    accentContrastColor: Binding<Color>
  ) {
    self.coverUrl = coverUrl
    self.mediaHeight = mediaHeight
    self.maxWidth = maxWidth
    self._coverYPosition = coverYPosition
    self._accentColor = accentColor
    self._accentContrastColor = accentContrastColor
  }
  
  public var body: some View {
    if let coverUrl = coverUrl {
      ImageView(coverUrl, contentMode: mediaHeight == nil ? .fit : .fill)
        .frame(maxWidth: maxWidth)
        .frame(height: mediaHeight)
        .clipped()
        .onGeometryChange(for: CGFloat.self) { geometry in
          geometry.frame(in: .named("scrollContentSpace")).maxY
        } action: { newY in
          coverYPosition = newY
        }
        .task {
          // Extract dominant color from the image URL
          await extractDominantColor(from: coverUrl)
        }
    }
  }
  
  private func extractDominantColor(from url: URL) async {
    if let (data, _) = try? await URLSession.shared.data(from: url),
       let uiImage = UIImage(data: data) {
      if let extractedColor = DominantColorExtractor.extractDominantColor(from: uiImage) {
        let color = Color(extractedColor)
        accentColor = color
        accentContrastColor = DominantColorExtractor.contrastingTextColor(for: color)
      }
    }
  }
}

#Preview {
  @Previewable @State var coverYPosition: CGFloat = 0
  @Previewable @State var accentColor: Color? = nil
  @Previewable @State var accentContrastColor: Color = .white
  
  return PromotionCoverView(
    coverUrl: URL(string: "https://images.unsplash.com/photo-1747760866743-97dff7918000"),
    mediaHeight: 300,
    maxWidth: 400,
    coverYPosition: $coverYPosition,
    accentColor: $accentColor,
    accentContrastColor: $accentContrastColor
  )
  .frame(height: 300)
}
