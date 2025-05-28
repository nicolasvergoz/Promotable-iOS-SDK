import SwiftUI

/// Reusable image view component that handles different loading states
struct ImageView: View {
    private let url: URL?
    private let contentMode: ContentMode
    
    init(_ url: URL?, contentMode: ContentMode = .fit) {
        self.url = url
        self.contentMode = contentMode
    }
    
    var body: some View {
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
    VStack(spacing: 20) {
        ImageView(URL(string: "https://picsum.photos/200"))
            .frame(width: 200, height: 200)
        
        ImageView(nil)
            .frame(width: 200, height: 200)
    }
}
