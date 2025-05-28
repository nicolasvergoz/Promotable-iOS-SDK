import SwiftUI

/// Component responsible for displaying the promotion header (icon, title, subtitle)
struct PromotionHeaderView: View {
    let title: String?
    let subtitle: String?
    let iconUrl: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            if let iconUrl = iconUrl {
                ImageView(iconUrl, contentMode: .fill)
                    .frameSquare(120)
                    .cornerRadius(16)
            }
            
            VStack(spacing: 0) {
                // Title
                if let title = title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
                
                // Subtitle
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary.opacity(0.8))
                }
            }
            
            if title != nil || subtitle != nil || iconUrl != nil {
                Divider().opacity(0.5)
            }
        }
    }
}

#Preview {
    VStack {
        PromotionHeaderView(
            title: "Some App",
            subtitle: "Une assurance qui vous rassure",
            iconUrl: URL(string: "https://plus.unsplash.com/premium_photo-1747810311019-a70e477281d9")
        )
        
        PromotionHeaderView(
            title: "App without icon",
            subtitle: "Just a subtitle",
            iconUrl: nil
        )
    }
    .padding()
}
