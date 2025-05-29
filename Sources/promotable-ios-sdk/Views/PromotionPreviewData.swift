import SwiftUI

// Extension to provide sample data for previews
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
      mediaHeight: 300,
      alt: "banner"
    ),
    action: Campaign.Action(
      label: "Action",
      url: URL(string: "https://vrgz.me")!
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
