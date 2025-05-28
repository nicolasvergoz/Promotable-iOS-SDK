import Foundation

struct CampaignsResponse: Codable {
  let campaigns: [Campaign]
}

struct Campaign: Identifiable, Codable, Sendable {
  let id: String
  let weight: Int
  let target: Campaign.Target?
  let promotions: [Campaign.Promotion]
}

extension Campaign {
  struct Target: Codable, Sendable {
    let platforms: [String]?
    let languages: [String]?
    let startDate: Date?
    let endDate: Date?
  }
  
  struct Promotion: Identifiable, Codable, Sendable {
    let id: String
    var title: String?
    var subtitle: String?
    var icon: Campaign.Image?
    var cover: Campaign.Cover?
    let action: Campaign.Action
    let content: [Campaign.Content]
    var weight: Int?
    var minDisplayDuration: Int?
    // TODO: Action button color: providedColor/extractedCoverColor/extractedIconColor/default
  }
  
  struct Image: Codable, Sendable {
    let imageUrl: URL
    var alt: String?
    var size: Campaign.Size?
  }
  
  struct Cover: Codable, Sendable {
    var mediaUrl: URL?
    var mediaHeight: CGFloat?
    var alt: String?
  }
  
  struct Action: Codable, Sendable {
    let label: String
    let url: URL
  }
  
  struct Content: Codable, Sendable {
    var imageURL: URL?
    let description: String
  }
  
  enum Size: String, Codable, Sendable {
    case small, medium, large
  }
}
