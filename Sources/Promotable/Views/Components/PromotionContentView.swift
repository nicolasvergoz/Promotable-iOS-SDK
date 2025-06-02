import SwiftUI

/// Component responsible for displaying promotion content items
public struct PromotionContentView: View {
  public let contentItems: [Promotion.Content]
  
  /// Creates a new PromotionContentView with the specified content items
  /// - Parameter contentItems: Array of content items to display
  public init(contentItems: [Promotion.Content]) {
    self.contentItems = contentItems
  }
  
  public var body: some View {
    if !contentItems.isEmpty {
      VStack(alignment: .leading, spacing: 20) {
        ForEach(contentItems, id: \.description) { item in
          contentItemRow(item: item)
        }
      }
    }
  }
  
  @ViewBuilder
  private func contentItemRow(item: Promotion.Content) -> some View {
    Text(item.description)
      .font(.body)
      .foregroundColor(.secondary)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  PromotionContentView(contentItems: [
    Promotion.Content(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tristique suscipit lacinia."),
    Promotion.Content(description: "Nulla facilisi. Cras vulputate, nisl nec finibus malesuada, nunc nisi ultricies orci.")
  ])
  .padding()
}
