import Foundation
import CoreGraphics

public struct PromotionsResponse: Codable, Hashable, Sendable {
  public let promotions: [Promotion]
  public let schemaVersion: String
  public let resetBalancingDate: Date?
  public let resetCumulativeDate: Date?
  
  public init(promotions: [Promotion], schemaVersion: String = "0.1.0", resetBalancingDate: Date? = nil, resetCumulativeDate: Date? = nil) {
    self.promotions = promotions
    self.schemaVersion = schemaVersion
    self.resetBalancingDate = resetBalancingDate
    self.resetCumulativeDate = resetCumulativeDate
  }
}

public struct Promotion: Identifiable, Codable, Sendable, Hashable {
  public let id: String
  public var title: String?
  public var subtitle: String?
  public var icon: Image?
  public var cover: Promotion.Cover?
  public let action: Action
  public let content: [Content]
  public var weight: Int?
  public var minDisplayDuration: Int?
  public var target: Promotion.Target?
  
  public init(id: String, title: String? = nil, subtitle: String? = nil, icon: Image? = nil, cover: Cover? = nil, action: Action, content: [Content], weight: Int? = nil, minDisplayDuration: Int? = nil, target: Target? = nil) {
    self.id = id
    self.title = title
    self.subtitle = subtitle
    self.icon = icon
    self.cover = cover
    self.action = action
    self.content = content
    self.weight = weight
    self.minDisplayDuration = minDisplayDuration
    self.target = target
  }
}

extension Promotion {
  public struct Target: Codable, Sendable, Hashable {
    public let platforms: [String]?
    public let languages: [String]?
    public let startDate: Date?
    public let endDate: Date?
    
    public init(platforms: [String]? = nil, languages: [String]? = nil, startDate: Date? = nil, endDate: Date? = nil) {
      self.platforms = platforms
      self.languages = languages
      self.startDate = startDate
      self.endDate = endDate
    }
  }
  
  public struct Image: Codable, Sendable, Hashable {
    public let imageUrl: URL
    public var alt: String?
    public var size: Size?
    
    public init(imageUrl: URL, alt: String? = nil, size: Size? = nil) {
      self.imageUrl = imageUrl
      self.alt = alt
      self.size = size
    }
  }
  
  public struct Cover: Codable, Sendable, Hashable {
    public var mediaUrl: URL?
    public var mediaHeight: CGFloat?
    public var alt: String?
    
    public init(mediaUrl: URL? = nil, mediaHeight: CGFloat? = nil, alt: String? = nil) {
      self.mediaUrl = mediaUrl
      self.mediaHeight = mediaHeight
      self.alt = alt
    }
  }
  
  public struct Action: Codable, Sendable, Hashable {
    public let label: String
    public let url: URL
    public var backgroundColor: String?
    
    public init(label: String, url: URL, backgroundColor: String? = nil) {
      self.label = label
      self.url = url
      self.backgroundColor = backgroundColor
    }
  }
  
  public struct Content: Codable, Sendable, Hashable {
    public var imageURL: URL?
    public let description: String
    
    public init(imageURL: URL? = nil, description: String) {
      self.imageURL = imageURL
      self.description = description
    }
  }
  
  public enum Size: String, Codable, Sendable, Hashable {
    case small, medium, large
  }
}
