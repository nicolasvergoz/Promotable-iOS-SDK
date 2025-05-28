import SwiftUI

/// Component responsible for displaying promotion content items
struct PromotionContentView: View {
    let contentItems: [Campaign.Content]
    
    var body: some View {
        if !contentItems.isEmpty {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(contentItems, id: \.description) { item in
                    contentItemRow(item: item)
                }
            }
        }
    }
    
    @ViewBuilder
    private func contentItemRow(item: Campaign.Content) -> some View {
        Text(item.description)
            .font(.body)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PromotionContentView(contentItems: [
        Campaign.Content(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam tristique suscipit lacinia."),
        Campaign.Content(description: "Nulla facilisi. Cras vulputate, nisl nec finibus malesuada, nunc nisi ultricies orci.")
    ])
    .padding()
}
