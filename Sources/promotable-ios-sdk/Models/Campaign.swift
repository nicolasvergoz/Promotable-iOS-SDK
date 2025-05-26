import Foundation

struct CampaignsResponse: Codable {
  let campaigns: [Campaign]
}

struct Campaign: Identifiable, Codable {
  let id: String
  let weight: Int
  let target: Campaign.Target?
  let promotions: [Campaign.Promotion]
}

extension Campaign {
  struct Target: Codable {
    let platforms: [String]?
    let locales: [String]?
    let displayAfter: Int?
    let startDate: Date?
    let endDate: Date?
  }
  
  struct Promotion: Identifiable, Codable {
    let id: String
    var title: String?
    var subtitle: String?
    var icon: Campaign.Image?
    var cover: Campaign.Cover?
    let action: Campaign.Action
    let content: [Campaign.Content]
    var weight: Int?
    var minDisplayDuration: Int?
    // TODO: TopGradientColorStrategy providedColor/extractedCoverColor/none
    // TODO: Action button strategy: providedColor/extractedCoverColor/extractedIconColor/default
  }
  
  struct Image: Codable {
    let imageUrl: URL
    var alt: String?
    var size: Campaign.Size?
  }
  
  struct Cover: Codable {
    var mediaUrl: URL?
    let mediaType: MediaType
    var mediaHeight: CGFloat?
    var alt: String?
  }
  
  struct Action: Codable {
    let label: String
    let url: URL
  }
  
  struct Content: Codable {
    var imageURL: URL?
    let description: String
  }
  
  enum Size: String, Codable {
    case small, medium, large
  }
  
  enum MediaType: String, Codable {
    case image, video
  }
}
