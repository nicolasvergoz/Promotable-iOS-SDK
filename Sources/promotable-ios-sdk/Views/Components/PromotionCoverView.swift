import SwiftUI

/// Component responsible for displaying the cover image and extracting its dominant color
struct PromotionCoverView: View {
    let coverUrl: URL?
    let mediaHeight: CGFloat?
    let topSafeAreaInset: CGFloat
    let maxWidth: CGFloat
    
    @Binding var coverYPosition: CGFloat
    @Binding var dominantColor: Color?
    @Binding var dominantTextColor: Color
    
    var body: some View {
        if let coverUrl = coverUrl {
            ImageView(coverUrl, contentMode: mediaHeight == nil ? .fit : .fill)
                .frame(maxWidth: maxWidth)
                .frame(height: mediaHeight)
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
            if let extractedColor = DominantColorExtractor.extractDominantColor(from: uiImage, topPercentage: 1.0) {
                let color = Color(extractedColor)
                dominantColor = color
                dominantTextColor = DominantColorExtractor.contrastingTextColor(for: color)
            }
        }
    }
}

#Preview {
    @State var coverYPosition: CGFloat = 0
    @State var dominantColor: Color? = nil
    @State var dominantTextColor: Color = .white
    
    return PromotionCoverView(
        coverUrl: URL(string: "https://images.unsplash.com/photo-1747760866743-97dff7918000"),
        mediaHeight: 300,
        topSafeAreaInset: 0,
        maxWidth: 400,
        coverYPosition: $coverYPosition,
        dominantColor: $dominantColor,
        dominantTextColor: $dominantTextColor
    )
    .frame(height: 300)
}
