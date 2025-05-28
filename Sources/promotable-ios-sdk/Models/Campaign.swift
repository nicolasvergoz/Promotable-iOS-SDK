import Foundation
import CoreGraphics

public struct CampaignsResponse: Codable, Hashable, Sendable {
  public let campaigns: [Campaign]
}

public struct Campaign: Identifiable, Codable, Sendable, Hashable {
  public let id: String
  public let weight: Int
  public let target: Campaign.Target?
  public let promotions: [Campaign.Promotion]
}

extension Campaign {
  public struct Target: Codable, Sendable, Hashable {
    public let platforms: [String]?
    public let languages: [String]?
    public let startDate: Date?
    public let endDate: Date?
  }
  
  public struct Promotion: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public var title: String?
    public var subtitle: String?
    public var icon: Campaign.Image?
    public var cover: Campaign.Cover?
    public let action: Campaign.Action
    public let content: [Campaign.Content]
    public var weight: Int?
    public var minDisplayDuration: Int?
    // TODO: Action button color: providedColor/extractedCoverColor/extractedIconColor/default
  }
  
  public struct Image: Codable, Sendable, Hashable {
    public let imageUrl: URL
    public var alt: String?
    public var size: Campaign.Size?
  }
  
  public struct Cover: Codable, Sendable, Hashable {
    public var mediaUrl: URL?
    public var mediaHeight: CGFloat?
    public var alt: String?
  }
  
  public struct Action: Codable, Sendable, Hashable {
    public let label: String
    public let url: URL
  }
  
  public struct Content: Codable, Sendable, Hashable {
    public var imageURL: URL?
    public let description: String
  }
  
  public enum Size: String, Codable, Sendable, Hashable {
    case small, medium, large
  }
}
